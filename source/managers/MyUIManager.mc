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
using Toybox.Time;

//
// CLASS
//

class MyUIManager {

  //
  // VARIABLES
  //

  // Manager references
  private var sensorManager as MySensorManager?;
  private var locationManager as MyLocationManager?;
  private var timerManager as MyTimerManager?;

  //
  // FUNCTIONS
  //

  function initialize(sensorMgr as MySensorManager, locationMgr as MyLocationManager, timerMgr as MyTimerManager) {
    self.sensorManager = sensorMgr;
    self.locationManager = locationMgr;
    self.timerManager = timerMgr;
  }

  function updateUi(_iEpoch as Number) as Void {
    //Sys.println("DEBUG: UIManager.updateUi()");

    // Check sensor data age
    if(self.sensorManager != null) {
      (self.sensorManager as MySensorManager).checkSensorDataAge(_iEpoch);
    }

    // Check position data age
    if(self.locationManager != null) {
      (self.locationManager as MyLocationManager).checkPositionDataAge(_iEpoch);
    }

    // Update UI
    if($.oMyView != null) {
      ($.oMyView as MyView).updateUi();
      if(self.timerManager != null) {
        (self.timerManager as MyTimerManager).setUpdateLastEpoch(_iEpoch);
      }
    }
  }

  function shouldUpdateUi(_iEpoch as Number) as Boolean {
    if(self.timerManager != null) {
      return _iEpoch - (self.timerManager as MyTimerManager).getUpdateLastEpoch() > 1;
    }
    return true;
  }

}