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
using Toybox.System as Sys;
using Toybox.Timer;

//
// CLASS
//

class MyTimerManager {

  //
  // VARIABLES
  //

  // UI update timer
  private var oUpdateTimer as Timer.Timer?;
  private var iUpdateLastEpoch as Number = 0;
  
  // Tones timer
  private var oTonesTimer as Timer.Timer?;
  private var iTonesTick as Number = 1000;
  private var iTonesLastTick as Number = 0;

  // Callback references
  private var updateCallback as Method?;
  private var tonesCallback as Method?;

  //
  // FUNCTIONS
  //

  function initialize() {
    // Initialize timer state
  }

  function setUpdateCallback(callback as Method) as Void {
    self.updateCallback = callback;
  }

  function setTonesCallback(callback as Method) as Void {
    self.tonesCallback = callback;
  }

  function startUpdateTimer() as Void {
    // Start UI update timer (every multiple of 5 seconds, to save energy)
    // NOTE: in normal circumstances, UI update will be triggered by position events (every ~1 second)
    self.oUpdateTimer = new Timer.Timer();
    var iUpdateTimerDelay = (60-Sys.getClockTime().sec)%5;
    if(iUpdateTimerDelay > 0) {
      (self.oUpdateTimer as Timer.Timer).start(method(:onUpdateTimer_init), 1000*iUpdateTimerDelay, false);
    }
    else {
      (self.oUpdateTimer as Timer.Timer).start(method(:onUpdateTimer), 5000, true);
    }
  }

  function stopUpdateTimer() as Void {
    if(self.oUpdateTimer != null) {
      (self.oUpdateTimer as Timer.Timer).stop();
      self.oUpdateTimer = null;
    }
  }

  function startTonesTimer() as Void {
    self.iTonesTick = 1000;
    self.iTonesLastTick = 0;
    self.oTonesTimer = new Timer.Timer();
    (self.oTonesTimer as Timer.Timer).start(method(:onTonesTimer), 100, true);
  }

  function stopTonesTimer() as Void {
    if(self.oTonesTimer != null) {
      (self.oTonesTimer as Timer.Timer).stop();
      self.oTonesTimer = null;
    }
  }

  function getUpdateLastEpoch() as Number {
    return self.iUpdateLastEpoch;
  }

  function setUpdateLastEpoch(epoch as Number) as Void {
    self.iUpdateLastEpoch = epoch;
  }

  function getTonesTick() as Number {
    return self.iTonesTick;
  }

  function getTonesLastTick() as Number {
    return self.iTonesLastTick;
  }

  function setTonesLastTick(tick as Number) as Void {
    self.iTonesLastTick = tick;
  }

  function incrementTonesTick() as Void {
    self.iTonesTick++;
  }

  //
  // TIMER CALLBACKS
  //

  function onUpdateTimer_init() as Void {
    self.onUpdateTimer();
    self.oUpdateTimer = new Timer.Timer();
    (self.oUpdateTimer as Timer.Timer).start(method(:onUpdateTimer), 5000, true);
  }

  function onUpdateTimer() as Void {
    if(self.updateCallback != null) {
      self.updateCallback.invoke();
    }
  }

  function onTonesTimer() as Void {
    if(self.tonesCallback != null) {
      self.tonesCallback.invoke();
    }
  }

}