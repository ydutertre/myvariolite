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
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MySettings {

  //
  // CONSTANTS
  //

  private const VARIO_RANGE_VALUES as Array<Float> = [3.0f, 6.0f, 9.0f];
  private const VARIO_SMOOTH_VALUES as Array<Float> = [0.2f, 0.5f, 0.7f, 1.0f];
  private const MIN_CLIMB_VALUES as Array<Float> = [0.0f, 0.1f, 0.2f, 0.3f, 0.4f, 0.5f];
  private const MIN_SINK_VALUES as Array<Float> = [-1.0f, -2.0f, -3.0f, -4.0f, -6.0f, -10.0f];

  //
  // VARIABLES
  //

  // Settings
  // ... altimeter
  public var fAltimeterCalibrationQNH as Float = 101325.0f;
  // ... variometer
  public var iVariometerRange as Number = 0;
  public var bVariometerAutoThermal as Boolean = true;
  public var bVariometerThermalDetect as Boolean = true;
  public var iVariometerSmoothing as Number = 1;
  public var iVariometerPlotRange as Number = 2;
  // ... sounds
  public var bSoundsVariometerTones as Boolean = true;
  public var bVariometerVibrations as Boolean = true;
  public var iMinimumClimb as Number = 2; // Default value of 0.2m/s climb threshold before sounds and vibrations are triggered
  public var iMinimumSink as Number = 1;
  // ... activity
  public var bActivityAutoStart as Boolean = true; //Auto-start recording after launch
  public var fActivityAutoSpeedStart as Float = 3.0f;
  // ... general
  public var iGeneralBackgroundColor as Number = Gfx.COLOR_WHITE;
  // ... units
  public var iUnitDistance as Number = -1;
  public var iUnitElevation as Number = -1;
  public var iUnitPressure as Number = -1;
  public var iUnitDirection as Number = 1;
  public var bUnitTimeUTC as Boolean = false;

  // Units
  // ... symbols
  public var sUnitDistance as String = "km";
  public var sUnitHorizontalSpeed as String = "km/h";
  public var sUnitElevation as String = "m";
  public var sUnitVerticalSpeed as String = "m/s";
  public var sUnitPressure as String = "mb";
  public var sUnitDirection as String = "txt";
  public var sUnitTime as String = "LT";
  // ... conversion coefficients
  public var fUnitDistanceCoefficient as Float = 0.001f;
  public var fUnitHorizontalSpeedCoefficient as Float = 3.6f;
  public var fUnitElevationCoefficient as Float = 1.0f;
  public var fUnitVerticalSpeedCoefficient as Float = 1.0f;
  public var fUnitPressureCoefficient as Float = 0.01f;

  // Other
  public var fVariometerRange as Float = 3.0f;
  public var fMinimumClimb as Float = 0.2;
  public var fMinimumSink as Float = 2.0;
  public var fVariometerSmoothing as Float = 0.5; //Standard deviation of altitude measurement at fixed altitude

  //
  // FUNCTIONS: self
  //

  function load() as Void {
    // Settings
    // ... altimeter
    self.setAltimeterCalibrationQNH(self.loadAltimeterCalibrationQNH());
    // ... variometer
    self.setVariometerRange(self.loadVariometerRange());
    self.setVariometerAutoThermal(self.loadVariometerAutoThermal());
    self.setVariometerThermalDetect(self.loadVariometerThermalDetect());
    self.setVariometerSmoothing(self.loadVariometerSmoothing());
    self.setVariometerPlotRange(self.loadVariometerPlotRange());
    // ... sounds and vibration
    self.setSoundsVariometerTones(self.loadSoundsVariometerTones());
    self.setVariometerVibrations(self.loadVariometerVibrations());
    self.setMinimumClimb(self.loadMinimumClimb());
    self.setMinimumSink(self.loadMinimumSink());
    // ... activity
    self.setActivityAutoStart(self.loadActivityAutoStart());
    self.setActivityAutoSpeedStart(self.loadActivityAutoSpeedStart());
    // ... general
    self.setGeneralBackgroundColor(self.loadGeneralBackgroundColor());
    // ... units
    self.setUnitDistance(self.loadUnitDistance());
    self.setUnitElevation(self.loadUnitElevation());
    self.setUnitPressure(self.loadUnitPressure());
    self.setUnitDirection(self.loadUnitDirection());
    self.setUnitTimeUTC(self.loadUnitTimeUTC());
  }

  function loadAltimeterCalibrationQNH() as Float {  // [Pa]
    return self.loadValue("userAltimeterCalibrationQNH", 101325.0f) as Float;
  }
  function saveAltimeterCalibrationQNH(_fValue as Float) as Void {  // [Pa]
    App.Properties.setValue("userAltimeterCalibrationQNH", _fValue as App.PropertyValueType);
  }
  function setAltimeterCalibrationQNH(_fValue as Float) as Void {  // [Pa]
    // REF: https://en.wikipedia.org/wiki/Atmospheric_pressure#Records
    if(_fValue > 110000.0f) {
      _fValue = 110000.0f;
    }
    else if(_fValue < 85000.0f) {
      _fValue = 85000.0f;
    }
    self.fAltimeterCalibrationQNH = _fValue;
  }

  function loadVariometerRange() as Number {
    return self.loadValue("userVariometerRange", 0) as Number;
  }
  function saveVariometerRange(_iValue as Number) as Void {
    App.Properties.setValue("userVariometerRange", _iValue as App.PropertyValueType);
  }
  function setVariometerRange(_iValue as Number) as Void {
    self.iVariometerRange = self.clampIndex(_iValue, self.VARIO_RANGE_VALUES);
    self.fVariometerRange = self.VARIO_RANGE_VALUES[self.iVariometerRange];
  }

  function loadVariometerPlotRange() as Number {
    return self.loadValue("userVariometerPlotRange", 1) as Number;
  }
  function saveVariometerPlotRange(_iValue as Number) as Void {
    App.Properties.setValue("userVariometerPlotRange", _iValue as App.PropertyValueType);
  }
  function setVariometerPlotRange(_iValue as Number) as Void {
    if(_iValue > 3) {
      _iValue = 3;
    }
    else if(_iValue < 1) {
      _iValue = 1;
    }
    self.iVariometerPlotRange = _iValue;
  }

  function loadVariometerAutoThermal() as Boolean {
    return self.loadValue("userVariometerAutoThermal", true) as Boolean;
  }
  function saveVariometerAutoThermal(_bValue as Boolean) as Void {
    App.Properties.setValue("userVariometerAutoThermal", _bValue as App.PropertyValueType);
  }
  function setVariometerAutoThermal(_bValue as Boolean) as Void {
    self.bVariometerAutoThermal = _bValue;
  }

  function loadVariometerThermalDetect() as Boolean {
    return self.loadValue("userVariometerThermalDetect", true) as Boolean;
  }
  function saveVariometerThermalDetect(_bValue as Boolean) as Void {
    App.Properties.setValue("userVariometerThermalDetect", _bValue as App.PropertyValueType);
  }
  function setVariometerThermalDetect(_bValue as Boolean) as Void {
    self.bVariometerThermalDetect = _bValue;
  }

  function loadVariometerSmoothing() as Number {
    return self.loadValue("userVariometerSmoothing", 1) as Number;
  }
  function saveVariometerSmoothing(_iValue as Number) as Void { 
    App.Properties.setValue("userVariometerSmoothing", _iValue as App.PropertyValueType);
  }
  function setVariometerSmoothing(_iValue as Number) as Void {
    self.iVariometerSmoothing = self.clampIndex(_iValue, self.VARIO_SMOOTH_VALUES);
    self.fVariometerSmoothing = self.VARIO_SMOOTH_VALUES[self.iVariometerSmoothing];
  }

  function loadSoundsVariometerTones() as Boolean {
    return self.loadValue("userSoundsVariometerTones", true) as Boolean;
  }
  function saveSoundsVariometerTones(_bValue as Boolean) as Void {
    App.Properties.setValue("userSoundsVariometerTones", _bValue as App.PropertyValueType);
  }
  function setSoundsVariometerTones(_bValue as Boolean) as Void {
    self.bSoundsVariometerTones = _bValue;
  }

  function loadVariometerVibrations() as Boolean {
    return self.loadValue("userVariometerVibrations", true) as Boolean;
  }
  function saveVariometerVibrations(_bValue as Boolean) as Void {
    App.Properties.setValue("userVariometerVibrations", _bValue as App.PropertyValueType);
  }
  function setVariometerVibrations(_bValue as Boolean) as Void {
    self.bVariometerVibrations = _bValue;
  }

  function loadMinimumClimb() as Number {
    return self.loadValue("userMinimumClimb", 2) as Number;
  }
  function saveMinimumClimb(_iValue as Number) as Void {  // [m/s]
    App.Properties.setValue("userMinimumClimb", _iValue as App.PropertyValueType);
  }
  function setMinimumClimb(_iValue as Number) as Void {
    self.iMinimumClimb = self.clampIndex(_iValue, self.MIN_CLIMB_VALUES);
    self.fMinimumClimb = self.MIN_CLIMB_VALUES[self.iMinimumClimb];
  }

  function loadMinimumSink() as Number {
    return self.loadValue("userMinimumSink", 1) as Number; 
  }
  function saveMinimumSink(_iValue as Number) as Void {  // [m/s]
    App.Properties.setValue("userMinimumSink", _iValue as App.PropertyValueType);
  }
  function setMinimumSink(_iValue as Number) as Void {
    self.iMinimumSink = self.clampIndex(_iValue, self.MIN_SINK_VALUES);
    self.fMinimumSink = self.MIN_SINK_VALUES[self.iMinimumSink];
  }

  function loadActivityAutoStart() as Boolean {
    return self.loadValue("userActivityAutoStart", true) as Boolean;
  }
  function saveActivityAutoStart(_bValue as Boolean) as Void {
    App.Properties.setValue("userActivityAutoStart", _bValue as App.PropertyValueType);
  }
  function setActivityAutoStart(_bValue as Boolean) as Void {
    self.bActivityAutoStart = _bValue;
  }

  function loadActivityAutoSpeedStart() as Float {  // [m/s]
    return self.loadValue("userActivityAutoSpeedStart", 3.0f) as Float;
  }
  function saveActivityAutoSpeedStart(_fValue as Float) as Void {  // [m/s]
    App.Properties.setValue("userActivityAutoSpeedStart", _fValue as App.PropertyValueType);
  }
  function setActivityAutoSpeedStart(_fValue as Float) as Void {  // [m/s]
    if(_fValue > 99.9f) {
      _fValue = 99.9f;
    }
    else if(_fValue < 0.0f) {
      _fValue = 0.0f;
    }
    self.fActivityAutoSpeedStart = _fValue;
  }

  function loadGeneralBackgroundColor() as Number {
    return self.loadValue("userGeneralBackgroundColor", Gfx.COLOR_WHITE) as Number;
  }
  function saveGeneralBackgroundColor(_iValue as Number) as Void {
    App.Properties.setValue("userGeneralBackgroundColor", _iValue as App.PropertyValueType);
  }
  function setGeneralBackgroundColor(_iValue as Number) as Void {
    self.iGeneralBackgroundColor = _iValue;
  }
  
  function loadUnitDistance() as Number {
    return self.loadValue("userUnitDistance", -1) as Number;
  }
  function saveUnitDistance(_iValue as Number) as Void {
    App.Properties.setValue("userUnitDistance", _iValue as App.PropertyValueType);
  }
  function setUnitDistance(_iValue as Number) as Void {
    if(_iValue < 0 or _iValue > 2) {
      _iValue = -1;
    }
    self.iUnitDistance = _iValue;
    if(self.iUnitDistance < 0) {  // ... auto
      var oDeviceSettings = Sys.getDeviceSettings();
      if(oDeviceSettings has :distanceUnits and oDeviceSettings.distanceUnits != null) {
        _iValue = oDeviceSettings.distanceUnits;
      }
      else {
        _iValue = Sys.UNIT_METRIC;
      }
    }
    if(_iValue == 2) {  // ... nautical
      // ... [nm]
      self.sUnitDistance = "nm";
      self.fUnitDistanceCoefficient = 0.000539956803456f;  // ... m -> nm
      // ... [kt]
      self.sUnitHorizontalSpeed = "kt";
      self.fUnitHorizontalSpeedCoefficient = 1.94384449244f;  // ... m/s -> kt
    }
    else if(_iValue == Sys.UNIT_STATUTE) {  // ... statute
      // ... [sm]
      self.sUnitDistance = "sm";
      self.fUnitDistanceCoefficient = 0.000621371192237f;  // ... m -> sm
      // ... [mph]
      self.sUnitHorizontalSpeed = "mph";
      self.fUnitHorizontalSpeedCoefficient = 2.23693629205f;  // ... m/s -> mph
    }
    else {  // ... metric
      // ... [km]
      self.sUnitDistance = "km";
      self.fUnitDistanceCoefficient = 0.001f;  // ... m -> km
      // ... [km/h]
      self.sUnitHorizontalSpeed = "km/h";
      self.fUnitHorizontalSpeedCoefficient = 3.6f;  // ... m/s -> km/h
    }
  }

  function loadUnitElevation() as Number {
    return self.loadValue("userUnitElevation", -1) as Number;
  }
  function saveUnitElevation(_iValue as Number) as Void {
    App.Properties.setValue("userUnitElevation", _iValue as App.PropertyValueType);
  }
  function setUnitElevation(_iValue as Number) as Void {
    if(_iValue < 0 or _iValue > 1) {
      _iValue = -1;
    }
    self.iUnitElevation = _iValue;
    if(self.iUnitElevation < 0) {  // ... auto
      var oDeviceSettings = Sys.getDeviceSettings();
      if(oDeviceSettings has :elevationUnits and oDeviceSettings.elevationUnits != null) {
        _iValue = oDeviceSettings.elevationUnits;
      }
      else {
        _iValue = Sys.UNIT_METRIC;
      }
    }
    if(_iValue == Sys.UNIT_STATUTE) {  // ... statute
      // ... [ft]
      self.sUnitElevation = "ft";
      self.fUnitElevationCoefficient = 3.280839895f;  // ... m -> ft
      // ... [ft/min]
      self.sUnitVerticalSpeed = "ft/m";
      self.fUnitVerticalSpeedCoefficient = 196.8503937f;  // ... m/s -> ft/min
    }
    else {  // ... metric
      // ... [m]
      self.sUnitElevation = "m";
      self.fUnitElevationCoefficient = 1.0f;  // ... m -> m
      // ... [m/s]
      self.sUnitVerticalSpeed = "m/s";
      self.fUnitVerticalSpeedCoefficient = 1.0f;  // ... m/s -> m/s
    }
  }

  function loadUnitPressure() as Number {
    return self.loadValue("userUnitPressure", -1) as Number;
  }
  function saveUnitPressure(_iValue as Number) as Void {
    App.Properties.setValue("userUnitPressure", _iValue as App.PropertyValueType);
  }
  function setUnitPressure(_iValue as Number) as Void {
    if(_iValue < 0 or _iValue > 1) {
      _iValue = -1;
    }
    self.iUnitPressure = _iValue;
    if(self.iUnitPressure < 0) {  // ... auto
      // NOTE: assume weight units are a good indicator of preferred pressure units
      var oDeviceSettings = Sys.getDeviceSettings();
      if(oDeviceSettings has :weightUnits and oDeviceSettings.weightUnits != null) {
        _iValue = oDeviceSettings.weightUnits;
      }
      else {
        _iValue = Sys.UNIT_METRIC;
      }
    }
    if(_iValue == Sys.UNIT_STATUTE) {  // ... statute
      // ... [inHg]
      self.sUnitPressure = "inHg";
      self.fUnitPressureCoefficient = 0.0002953f;  // ... Pa -> inHg
    }
    else {  // ... metric
      // ... [mb/hPa]
      self.sUnitPressure = "mb";
      self.fUnitPressureCoefficient = 0.01f;  // ... Pa -> mb/hPa
    }
  }

  function loadUnitDirection() as Number {
    return self.loadValue("userUnitDirection", 1) as Number;
  }
  function saveUnitDirection(_iValue as Number) as Void {
    App.Properties.setValue("userUnitDirection", _iValue as App.PropertyValueType);
  }
  function setUnitDirection(_iValue as Number) as Void {
    if(_iValue < 0 or _iValue > 1) {
      _iValue = 1;
    }
    self.iUnitDirection = _iValue;
    if(_iValue == 1) {  // ... Text
      // ... txt
      self.sUnitDirection = "txt";
    }
    else {  // ... Degrees
      self.sUnitDirection = "°";
    }
  }

  function loadUnitTimeUTC() as Boolean {
    return self.loadValue("userUnitTimeUTC", false) as Boolean;
  }
  function saveUnitTimeUTC(_bValue as Boolean) as Void {
    App.Properties.setValue("userUnitTimeUTC", _bValue as App.PropertyValueType);
  }
  function setUnitTimeUTC(_bValue as Boolean) as Void {
    self.bUnitTimeUTC = _bValue;
    if(_bValue) {
      self.sUnitTime = "Z";
    }
    else {
      self.sUnitTime = "LT";
    }
  }

  //
  // Private Functions
  //

  private function clampIndex(_iValue as Number, _fArray as Array) as Number {
    if (_iValue < 0) { return 0; }
    if (_iValue >= _fArray.size()) { return _fArray.size() - 1; }
    return _iValue;
  }

  private function loadValue(_sKey as String, _oDefaultValue as Object) as Object {
    var val = App.Properties.getValue(_sKey);
    return val != null ? val : _oDefaultValue;
  }

}
