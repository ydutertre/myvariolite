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
using Toybox.Position as Pos;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class MyDrawableHeader extends Ui.Drawable {

  //
  // VARIABLES
  //

  // Constants
  private const BAR_HEIGHTS as Array<Number> = [8, 12, 16, 20];

  // Background color
  private var iColorBackground as Number = Gfx.COLOR_TRANSPARENT;

  // Position accuracy
  private var iPositionAccuracy as Number = Pos.QUALITY_NOT_AVAILABLE;


  //
  // FUNCTIONS: Ui.Drawable (override/implement)
  //

  function initialize() {
    Drawable.initialize({:identifier => "MyDrawableHeader"});

  }

  function draw(_oDC) {
    // Draw background
    _oDC.setColor(self.iColorBackground, self.iColorBackground);
    _oDC.clear();

    // Determine color and number of bars to highlight
    var iBars = 0;
    var iColor = Gfx.COLOR_LT_GRAY;
    switch(self.iPositionAccuracy) {

      case Pos.QUALITY_GOOD:
        iBars = 4;
        iColor = Gfx.COLOR_DK_GREEN;
        break;

      case Pos.QUALITY_USABLE:
        iBars = 3;
        iColor = Gfx.COLOR_ORANGE;
        break;

      case Pos.QUALITY_POOR:
        iBars = 2;
        iColor = Gfx.COLOR_RED;
        break;

      case Pos.QUALITY_LAST_KNOWN:
        iBars = 1;
        iColor = Gfx.COLOR_DK_RED;
        break;

      case Pos.QUALITY_NOT_AVAILABLE:
      default:
        iBars = 0;
        break;
    }

    // Geometry
    self.drawAccuracyBars(_oDC, iBars, iColor);

  }


  //
  // FUNCTIONS: self
  //

  function setColorBackground(_iColorBackground as Number) as Void {
    self.iColorBackground = _iColorBackground;
  }

  function setPositionAccuracy(_iPositionAccuracy as Number) as Void {
    self.iPositionAccuracy = _iPositionAccuracy;
  }

  //
  // FUNCTIONS: private
  //

  private function drawAccuracyBars(_dc as Gfx.Dc, _iBars as Number, _iColor as Number) as Void {
    var w = _dc.getWidth();
    var h = _dc.getHeight();

    var baseX = (0.5f * w).toNumber() - 11; // Left bar
    var baseline = (0.1f * h + 1).toNumber(); // Bottom anchor

    for (var i = 0; i < BAR_HEIGHTS.size(); i++) {
      if (i < _iBars) {
        _dc.setColor(_iColor, Gfx.COLOR_TRANSPARENT);
      } else {
        _dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
      }
      _dc.fillRectangle(baseX + i * 6, baseline - self.BAR_HEIGHTS[i], 4, self.BAR_HEIGHTS[i]);
    }
  }

}
