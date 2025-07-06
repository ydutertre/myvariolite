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

//
// CLASS
//

class MyActivityManager {

  function initialize() {
  }
  
  function checkAutoStart() as Void {
    // Exit if auto-start is disabled or activity is already running
    if (!$.oMySettings.bActivityAutoStart or $.oMyActivity != null) {
        return;
    }

    // Get ground speed and speed threshold
    var fGroundSpeed = $.oMyProcessing.fGroundSpeed;
    var fMinSpeedThreshold = $.oMySettings.fActivityAutoSpeedStart;

    // Validate data and start activity if conditions are met
    if (LangUtils.notNaN(fGroundSpeed) and fMinSpeedThreshold > 0.0f and fGroundSpeed > fMinSpeedThreshold) {
        $.oMyActivity = new MyActivity();
        ($.oMyActivity as MyActivity).start();
    }
  }
}
