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
using Toybox.Position as Pos;
using Toybox.Time;

//
// CLASS
//

class MyLocationManager {

  //
  // FUNCTIONS
  //

  function initialize() { 
  }

  function enableLocationEvents(callback as Method) as Void {
    Pos.enableLocationEvents(Pos.LOCATION_CONTINUOUS, callback);
  }

  function disableLocationEvents(callback as Method) as Void {
    Pos.enableLocationEvents(Pos.LOCATION_DISABLE, callback);
  }

  function processLocationEvent(_oInfo as Pos.Info, _iEpoch as Number, _oTimeNow as Time.Moment) as Void {
    // Save location
    if(_oInfo has :position) {
      $.oMyPositionLocation = _oInfo.position;
    }

    // Save altitude
    if(_oInfo has :altitude and _oInfo.altitude != null) {
      $.fMyPositionAltitude = _oInfo.altitude as Float;
    }

    // Process position data
    $.oMyProcessing.processPositionInfo(_oInfo, _iEpoch);
    if($.oMyActivity != null) {
      ($.oMyActivity as MyActivity).processPositionInfo(_oInfo, _iEpoch, _oTimeNow);
    }
  }

  function checkPositionDataAge(currentEpoch as Number) as Void {
    // Check position data age
    if($.oMyProcessing.iPositionEpoch >= 0 and currentEpoch-$.oMyProcessing.iPositionEpoch > 10) {
      $.oMyProcessing.resetPositionData();
    }
  }
}
