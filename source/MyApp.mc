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
// My Vario is based on Glider's Swiss Knife (GliderSK) by Cedric Dufour

// Glider's Swiss Knife (GliderSK)
// Copyright (C) 2017-2022 Cedric Dufour <http://cedric.dufour.name>
//
// Glider's Swiss Knife (GliderSK) is free software:
// you can redistribute it and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation, Version 3.
//
// Glider's Swiss Knife (GliderSK) is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// See the GNU General Public License for more details.
//
// SPDX-License-Identifier: GPL-3.0
// License-Filename: LICENSE/GPL-3.0.txt

import Toybox.Lang;
using Toybox.Activity;
using Toybox.Application as App;
using Toybox.Attention as Attn;
using Toybox.Communications as Comm;
using Toybox.Position as Pos;
using Toybox.Sensor;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Timer;
using Toybox.WatchUi as Ui;

//
// GLOBALS
//

// Application settings
var oMySettings as MySettings = new MySettings() ;

// (Last) position location/altitude
var oMyPositionLocation as Pos.Location?;
var fMyPositionAltitude as Float = NaN;

// Sensors filter
var oMyKalmanFilter as MyKalmanFilter = new MyKalmanFilter();

// Internal altimeter
var oMyAltimeter as MyAltimeter = new MyAltimeter();

// Processing logic
var oMyProcessing as MyProcessing = new MyProcessing();
var oMyTimeStart as Time.Moment = Time.now();

// Activity session (recording)
var oMyActivity as MyActivity?;

// Current view
var oMyView as MyView?;


//
// CONSTANTS
//

// No-value strings
// NOTE: Those ought to be defined in the MyApp class like other constants but code then fails with an "Invalid Value" error when called upon; BUG?
const MY_NOVALUE_BLANK = "";
const MY_NOVALUE_LEN2 = "--";
const MY_NOVALUE_LEN3 = "---";
const MY_NOVALUE_LEN4 = "----";


//
// CLASS
//

class MyApp extends App.AppBase {

  //
  // CONSTANTS
  //

  // FIT fields (as per resources/fit.xml)
  public const FITFIELD_VERTICALSPEED = 0;
  public const FITFIELD_BAROMETRICALTITUDE = 1;

  //
  // VARIABLES
  //

  // Manager instances
  private var oTimerManager as MyTimerManager = new MyTimerManager();
  private var oSensorManager as MySensorManager = new MySensorManager();
  private var oLocationManager as MyLocationManager = new MyLocationManager();
  private var oAudioManager as MyAudioManager = new MyAudioManager(self.oTimerManager);
  private var oActivityManager as MyActivityManager = new MyActivityManager();
  private var oUiManager as MyUIManager = new MyUIManager(self.oSensorManager, self.oLocationManager, self.oTimerManager);

  //
  // FUNCTIONS: App.AppBase (override/implement)
  //

  function initialize() {
    AppBase.initialize();

    // Set up callbacks
    self.oTimerManager.setUpdateCallback(method(:onUpdateTimerCallback));
    self.oTimerManager.setTonesCallback(method(:onTonesTimerCallback));

    // Timers
    $.oMyTimeStart = Time.now();
  }

  function onStart(state) {
    //Sys.println("DEBUG: MyApp.onStart()");

    // Load settings
    self.loadSettings();

    // Enable sensor events
    self.oSensorManager.enableSensorEvents(method(:onSensorEvent));

    // Enable position events
    self.oLocationManager.enableLocationEvents(method(:onLocationEvent));

    // Start UI update timer
    self.oTimerManager.startUpdateTimer();
  }

  function onStop(state) {
    //Sys.println("DEBUG: MyApp.onStop()");

    // Stop timers
    self.oTimerManager.stopUpdateTimer();
    self.oAudioManager.muteTones();

    // Disable position events
    self.oLocationManager.disableLocationEvents(method(:onLocationEvent));

    // Disable sensor events
    self.oSensorManager.disableSensorEvents();
  }

  function getInitialView() {
    //Sys.println("DEBUG: MyApp.getInitialView()");

    return [new MyViewGeneral(), new MyViewGeneralDelegate()];
  }

  function onSettingsChanged() {
    //Sys.println("DEBUG: MyApp.onSettingsChanged()");
    self.loadSettings();
    self.oUiManager.updateUi(Time.now().value());
  }

  //
  // FUNCTIONS: Event Handlers
  //

  function onSensorEvent(_oInfo as Sensor.Info) as Void {
    //Sys.println("DEBUG: MyApp.onSensorEvent());

    // Process altimeter data
    self.oSensorManager.processSensorEvent(_oInfo);
  }

  function onLocationEvent(_oInfo as Pos.Info) as Void {
    //Sys.println("DEBUG: MyApp.onLocationEvent()");
    var oTimeNow = Time.now();
    var iEpoch = oTimeNow.value();

    // Process position data
    self.oLocationManager.processLocationEvent(_oInfo, iEpoch, oTimeNow);

    // Automatic Activity recording
    self.oActivityManager.checkAutoStart();

    // UI update
    self.oUiManager.updateUi(iEpoch);
  }

  function onUpdateTimerCallback() as Void {
    //Sys.println("DEBUG: MyApp.onUpdateTimerCallback()");
    var iEpoch = Time.now().value();
    if (self.oUiManager.shouldUpdateUi(iEpoch)) {
      self.oUiManager.updateUi(iEpoch);
    }
  }

  function onTonesTimerCallback() as Void {
    //Sys.println("DEBUG: MyApp.onTonesTimerCallback()");
    self.oAudioManager.playTones();
  }

  //
  // FUNCTIONS: Settings Management
  //

  function loadSettings() as Void {
    //Sys.println("DEBUG: MyApp.loadSettings()");

    // Load settings
    $.oMySettings.load();

    // Apply settings
    $.oMyAltimeter.importSettings();

    // ... tones
    self.oAudioManager.muteTones();
  }

  //
  // FUNCTIONS: Audio Management
  // NOTE: For Use in MyView*.mc
  //

  function muteTones() as Void {
    self.oAudioManager.muteTones();
  }

  function unmuteTones() as Void {
    self.oAudioManager.unmuteTones();
  }

}
