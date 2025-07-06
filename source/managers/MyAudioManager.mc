// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// My Vario
// Copyright (C) 2022 Yannick Dutertre <https://yannickd9.wixsite.com/>
//
// My Vario is free software:
// you can redistribute it and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation, Version 3.
//
// My Vario is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// See the GNU General Public License for more details.
//
// SPDX-License-Identifier: GPL-3.0
// License-Filename: LICENSE/GPL-3.0.txt

import Toybox.Lang;
using Toybox.Attention as Attn;

//
// CLASS
//

class MyAudioManager {

  //
  // VARIABLES
  //

  // Audio/vibration state
  private var bTones as Boolean = false;
  private var bVibrations as Boolean = false;
  private var bSinkToneTriggered as Boolean = false;

  // Timer manager reference
  private var timerManager as MyTimerManager?;

  //
  // FUNCTIONS
  //

  function initialize(timerMgr as MyTimerManager) {
    self.timerManager = timerMgr;
  }

  function muteTones() as Void {
    // Stop tones timers
    if(self.timerManager != null) {
      (self.timerManager as MyTimerManager).stopTonesTimer();
    }
  }

  function unmuteTones() as Void {
    // Enable tones
    self.bTones = false;
    if(Toybox.Attention has :playTone) {
      if($.oMySettings.bSoundsVariometerTones) {
        self.bTones = true;
      }
    }

    self.bVibrations = false;
    if(Toybox.Attention has :vibrate) {
      if($.oMySettings.bVariometerVibrations) {
        self.bVibrations = true;
      }
    }

    // Start tones timer
    // NOTE: For variometer tones, we need a 10Hz <-> 100ms resolution;
    if(self.bTones || self.bVibrations) {
      if(self.timerManager != null) {
        (self.timerManager as MyTimerManager).startTonesTimer();
      }
    }
  }

  function playTones() as Void {
    //Sys.println(format("DEBUG: AudioManager.playTones() @ $1$", [self.timerManager.getTonesTick()]));
    // Variometer
    // ALGO: Tones "tick" is 100ms; I try to do a curve that is similar to the Skybean vario
    // Medium curve in terms of tone length, pause, and one frequency.
    // Tones need to be more frequent than in GliderSK even at low climb rates to be able to
    // properly map thermals (especially broken up thermals)
    if(self.bTones || self.bVibrations) {
      var fValue = $.oMyProcessing.fVariometer_filtered;
      var iTonesTick = (self.timerManager as MyTimerManager).getTonesTick();
      var iTonesLastTick = (self.timerManager as MyTimerManager).getTonesLastTick();
      var iDeltaTick = (iTonesTick-iTonesLastTick) > 8 ? 8 : iTonesTick-iTonesLastTick;
      
      if(fValue >= $.oMySettings.fMinimumClimb && iDeltaTick >= 8.0f - fValue) {
        //Sys.println(format("DEBUG: playTone: variometer @ $1$", [iTonesTick]));
        var iToneLength = (iDeltaTick > 2) ? iDeltaTick * 50 - 100: 50;
        if(self.bTones) {
          var iToneFrequency = (400 + fValue * 100) > 1100 ? 1100 : (400 + fValue * 100).toNumber();
          var toneProfile = [new Attn.ToneProfile(iToneFrequency, iToneLength)]; //contrary to Garmin API Doc, first parameter seems to be frequency, and second length
          Attn.playTone({:toneProfile=>toneProfile});
        }
        if(self.bVibrations) {
          var vibeData = [new Attn.VibeProfile(100, (iToneLength > 200) ? iToneLength / 2 : 50)]; //Keeping vibration length shorter than tone for battery and wrist!
          Attn.vibrate(vibeData);
        }
        (self.timerManager as MyTimerManager).setTonesLastTick(iTonesTick);
        return;
      }
      else if(fValue <= $.oMySettings.fMinimumSink && !self.bSinkToneTriggered && self.bTones) {
        var toneProfile = [new Attn.ToneProfile(220, 2000)];
        Attn.playTone({:toneProfile=>toneProfile});
        self.bSinkToneTriggered = true;
      }
      //Reset minimum sink tone if we get significantly above it
      if(fValue >= $.oMySettings.fMinimumSink + 1.0f && self.bSinkToneTriggered) {
        self.bSinkToneTriggered = false;
      }
    }
  }

}