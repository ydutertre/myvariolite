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
// This Kalman filter is based on the implementation for Arduino Variometer
// by Baptiste PELLEGRIN
// https://github.com/prunkdump/arduino-variometer/blob/master/libraries/kalmanvert/kalmanvert.cpp

import Toybox.Lang;
using Toybox.Math;
using Toybox.System as Sys;

//
// CLASS
//

class MyKalmanFilter {

  //
  // CONSTANTS
  //

  private const ACCELERATION_VARIANCE = 0.36f; //Value 0.36 taken from Arduino-vario, when no accelerometer present (as of now, because gyro data isn't accessible, the watch accelerometer can't be used)
  

  //
  // VARIABLES
  //

  // Covariance matrix (as floats)
  private var p11 as Float = 0.0f;
  private var p12 as Float = 0.0f;
  private var p21 as Float = 0.0f;
  private var p22 as Float = 0.0f;

  // Position, velocity, acceleration, timestamp
  public var fPosition as Float = 0.0f;
  public var fVelocity as Float = 0.0f;
  public var fAcceleration as Float = 0.0f;
  public var iTimestamp as Number = 0;

  // Filter ready?
  public var bFilterReady as Boolean = false;

  //
  // FUNCTIONS: self
  //

  function init(_fStartP as Float, _fStartA as Float, _iTimestamp as Number) as Void {
    self.fPosition = _fStartP;
    self.fVelocity = 0.0f;
    self.fAcceleration = _fStartA;
    self.iTimestamp = _iTimestamp;

    self.p11 = 0.0f;
    self.p12 = 0.0f;
    self.p21 = 0.0f;
    self.p22 = 0.0f;

    self.bFilterReady = true;
  }

  function update(_fPosition as Float, _fAcceleration as Float, _iTimestamp as Number) as Void {
    // Delta time
    var deltaTime = _iTimestamp - iTimestamp;
    var dt = deltaTime.toFloat();
    if (dt == 0.0f) { return; }
    self.iTimestamp = _iTimestamp;

    // Variance
    var fAltitudeVariance = $.oMySettings.fVariometerSmoothing * $.oMySettings.fVariometerSmoothing;

    // Prediction
    self.predictState(dt, _fAcceleration, self.ACCELERATION_VARIANCE);

    // Gaussian Product
    self.updateState(_fPosition, fAltitudeVariance);
  }

  //
  // Private Functions
  //

  private function predictState(_fDt as Float, _fAcceleration as Float, _fAccelerationVariance as Float) as Void {
    // Values
    self.fAcceleration = _fAcceleration;

    // Time powers
    var dt = _fDt;
    var dt2 = dt * dt;
    var dt3 = dt2 * dt;
    var dt4 = dt2 * dt2;

    // Predict position and velocity
    self.fPosition += dt * self.fVelocity + 0.5f * dt2 * self.fAcceleration;
    self.fVelocity += dt * self.fAcceleration;

    // Covariance updates
    var inc = dt * self.p22 + 0.5f * dt3 * _fAccelerationVariance;
    self.p11 += dt * (self.p12 + self.p21 + inc) - (0.25f * dt4 * _fAccelerationVariance);
    self.p21 += inc;
    self.p12 += inc;
    self.p22 += dt2 * _fAccelerationVariance;
  }

  private function updateState(_fPosition as Float, _fAltitudeVariance as Float) as Void {
    // Kalman gain
    var s = self.p11 + _fAltitudeVariance;
    var k11 = self.p11 / s;
    var k12 = self.p12 / s;

    // Innovation
    var y = _fPosition - self.fPosition;

    // State update
    self.fPosition += k11 * y;
    self.fVelocity += k12 * y;

    // Covariance update
    self.p22 -= k12 * self.p21;
    self.p12 -= k12 * self.p11;
    self.p21 -= k11 * self.p21;
    self.p11 -= k11 * self.p11;
  }
}
