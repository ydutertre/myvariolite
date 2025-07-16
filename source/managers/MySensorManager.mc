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
using Toybox.Activity;
using Toybox.Sensor;
using Toybox.Time;

//
// CLASS
//

class MySensorManager {

  //
  // FUNCTIONS
  //

  function initialize() {
    // Initialize sensor manager
  }

  function enableSensorEvents(callback as Method) as Void {
    Sensor.setEnabledSensors([] as Array<Sensor.SensorType>);  // ... we need just the acceleration
    Sensor.enableSensorEvents(callback);
  }

  function disableSensorEvents() as Void {
    Sensor.enableSensorEvents(null);
  }

  function processSensorEvent(_oInfo as Sensor.Info) as Void {
    // Process altimeter data
    var oActivityInfo = Activity.getActivityInfo();  // ... we need *raw ambient* pressure
    if (oActivityInfo != null) {
      if (oActivityInfo has :rawAmbientPressure and oActivityInfo.rawAmbientPressure != null) {
        $.oMyAltimeter.setQFE(oActivityInfo.rawAmbientPressure as Float);
        //Sys.println(format("First altimeter run $1$", [$.oMyAltimeter.bFirstRun]));        
        //Initial automated calibration based on watch altitude
        if($.oMyAltimeter.bFirstRun && _oInfo has :altitude && _oInfo.altitude != null) {
          $.oMyAltimeter.bFirstRun = false;
          $.oMyAltimeter.setAltitudeActual(_oInfo.altitude);
          $.oMySettings.saveAltimeterCalibrationQNH($.oMyAltimeter.fQNH);
        }
      }
    }

    // Process sensor data
    $.oMyProcessing.processSensorInfo(_oInfo, Time.now().value());

    // Save FIT fields
    if ($.oMyActivity != null) {
      ($.oMyActivity as MyActivity).setBarometricAltitude($.oMyProcessing.fAltitude);
      ($.oMyActivity as MyActivity).setVerticalSpeed($.oMyProcessing.fVariometer);
    }
  }

  function checkSensorDataAge(currentEpoch as Number) as Void {
    // Check sensor data age
    if ($.oMyProcessing.iSensorEpoch >= 0 and currentEpoch-$.oMyProcessing.iSensorEpoch > 10) {
      $.oMyProcessing.resetSensorData();
      $.oMyAltimeter.reset();
    }
  }
}
