import Toybox.System;
import Toybox.Math;
import Toybox.Test;

const fMaxRmsePos = 2.0f;  // Maximum RMSE allowed for position estimate
const fMaxRmseVel = 1.0f;  // Maximum RMSE allowed for velocity estimate
const iTotalTime = 180;    // Total time to run the test [s]

// === Helpers ===

/**
 * Generates random Gaussian-like noise with zero mean and specified standard deviation.
 * Used to simulate noisy measurements in the filter tests.
 */
function fGenNoise(fNoiseStdDev) {
  return fNoiseStdDev * (2.0f * Math.rand().toFloat() / 0x7FFFFFFF - 1.0f);
}

/**
 * Calculates root-mean-square error from the sum of squared errors and number of samples.
 * Used as a performance metric to validate Kalman filter accuracy.
 */
function fCalcRMSE(fSumSqErr, iSteps) {
  return Math.sqrt(fSumSqErr / iSteps);
}

// === Tests ===

/**
 * Verifies that the Kalman filter converges toward a constant position value
 * despite noisy measurements and a poor initial guess.
 * This is the most basic test of filter stability and convergence.
 */
(:test)
function testStaticPositionFilterConverges(oLogger) {
  var fInitialPos = 10.0f;
  var fNoiseStdDev = 2.0f;

  var oFilter = new MyKalmanFilter();
  oFilter.init(fInitialPos + 5.0f, 0.0f, 0);

  var fTotalSqErr = 0.0f;

  System.println("t, truePos, noisyPos, estPos");

  for (var iT = 1; iT <= iTotalTime; iT++) {
    var fNoisyPos = fInitialPos + fGenNoise(fNoiseStdDev);
    oFilter.update(fNoisyPos, 0.0f, iT);

    var fEst = oFilter.fPosition;
    var fErr = fEst - fInitialPos;
    fTotalSqErr += fErr * fErr;

    if (iT < 10 || iT > iTotalTime - 10) {
      System.println("t=" + iT +
                  ", truePos=" + fInitialPos.format("%.2f") +
                  ", noisyPos=" + fNoisyPos.format("%.2f") +
                  ", estPos=" + fEst.format("%.2f"));
    }
  }

  var fRmse = fCalcRMSE(fTotalSqErr, iTotalTime);
  System.println("Final RMSE: " + fRmse.format("%.2f"));

  return fRmse < fMaxRmsePos;
}

/**
 * Validates that the Kalman filter can correctly estimate velocity over time
 * when the object moves at constant velocity with noisy position updates.
 * Confirms the velocity state estimation is working.
 */
(:test)
function testConstantVelocityTracking(oLogger) {
  var fInitialPos = 0.0f;
  var fVelocity = 2.0f;
  var fAcc = 0.0f;
  var fNoiseStdDev = 1.0f;

  var oFilter = new MyKalmanFilter();
  oFilter.init(fInitialPos, fAcc, 0);

  var fTotalSqVelErr = 0.0f;

  System.println("t, truePos, noisyPos, estPos, estVel");

  for (var iT = 1; iT <= iTotalTime; iT++) {
    var fTruePos = fInitialPos + fVelocity * iT;

    var fNoisyPos = fTruePos + fGenNoise(fNoiseStdDev);

    oFilter.update(fNoisyPos, fAcc, iT);

    var fVelErr = oFilter.fVelocity - fVelocity;
    fTotalSqVelErr += fVelErr * fVelErr;

    if (iT < 10 || iT > iTotalTime - 10) {
      System.println("t=" + iT +
                  ", truePos=" + fTruePos.format("%.2f") +
                  ", noisyPos=" + fNoisyPos.format("%.2f") +
                  ", estPos=" + oFilter.fPosition.format("%.2f") +
                  ", estVel=" + oFilter.fVelocity.format("%.2f"));
    }
  }

  var fRmseVel = fCalcRMSE(fTotalSqVelErr, iTotalTime);
  System.println("Velocity RMSE: " + fRmseVel.format("%.2f"));

  return fRmseVel < fMaxRmseVel;
}

/**
 * Tests filter behavior under constant acceleration (e.g. free fall, gravity).
 * Validates both position and velocity estimation under nonlinear motion.
 */
(:test)
function testConstantAccelerationTracking(oLogger) {
  var fAcc = 0.5f;
  var fInitialPos = 0.0f;
  var fInitialVel = 0.0f;
  var fNoiseStdDev = 1.0f;

  var oFilter = new MyKalmanFilter();
  oFilter.init(fInitialPos, fAcc, 0);

  var fTotalSqPosErr = 0.0f;
  var fTotalSqVelErr = 0.0f;

  System.println("t, truePos, noisyPos, estPos, trueVel, estVel");

  for (var iT = 1; iT <= iTotalTime; iT++) {
    var fTruePos = fInitialPos + fInitialVel * iT + 0.5f * fAcc * iT * iT;
    var fTrueVel = fInitialVel + fAcc * iT;

    var fNoisyPos = fTruePos + fGenNoise(fNoiseStdDev);

    oFilter.update(fNoisyPos, fAcc, iT);

    var fPosErr = oFilter.fPosition - fTruePos;
    var fVelErr = oFilter.fVelocity - fTrueVel;

    fTotalSqPosErr += fPosErr * fPosErr;
    fTotalSqVelErr += fVelErr * fVelErr;

    if (iT < 10 || iT > iTotalTime - 10) {
      System.println("t=" + iT +
                  ", truePos=" + fTruePos.format("%.2f") +
                  ", estPos=" + oFilter.fPosition.format("%.2f") +
                  ", trueVel=" + fTrueVel.format("%.2f") +
                  ", estVel=" + oFilter.fVelocity.format("%.2f"));
    }
  }

  var fRmsePos = fCalcRMSE(fTotalSqPosErr, iTotalTime);
  var fRmseVel = fCalcRMSE(fTotalSqVelErr, iTotalTime);

  System.println("Position RMSE: " + fRmsePos.format("%.2f"));
  System.println("Velocity RMSE: " + fRmseVel.format("%.2f"));

  return fRmsePos < fMaxRmsePos && fRmseVel < fMaxRmseVel;
}

/**
 * Tests how the filter responds to a sudden change in position (step function).
 * This simulates a real-world scenario like a GPS jump or barometric jump.
 * Checks whether the filter smoothly recovers and re-converges.
 */
(:test)
function testStepChangeRecovery(oLogger) {
  var fInitialPos = 0.0f;
  var fNoiseStdDev = 1.0f;
  var iStepTime = 90;  // Sudden change at t = 90
  var fStepSize = 20.0f;

  var oFilter = new MyKalmanFilter();
  oFilter.init(fInitialPos, 0.0f, 0);

  var fTotalSqErr = 0.0f;

  System.println("t, truePos, noisyPos, estPos");

  for (var iT = 1; iT <= iTotalTime; iT++) {
    var fTruePos = iT < iStepTime ? fInitialPos : fInitialPos + fStepSize;
    var fNoisyPos = fTruePos + fGenNoise(fNoiseStdDev);

    oFilter.update(fNoisyPos, 0.0f, iT);

    var fErr = oFilter.fPosition - fTruePos;
    fTotalSqErr += fErr * fErr;

    if (iT < 10 || iT > iTotalTime - 10 || iT == iStepTime || iT == iStepTime + 1) {
      System.println("t=" + iT +
                  ", truePos=" + fTruePos.format("%.2f") +
                  ", noisyPos=" + fNoisyPos.format("%.2f") +
                  ", estPos=" + oFilter.fPosition.format("%.2f"));
    }
  }

  var fRmse = fCalcRMSE(fTotalSqErr, iTotalTime);
  System.println("Final RMSE (Step Recovery): " + fRmse.format("%.2f"));

  return fRmse < 5.0f;  // Relaxed due to the step disturbance
}

/**
 * Simulates intermittent measurement dropout (e.g. lost sensor packets).
 * Verifies that the filter remains stable and continues estimation
 * using the process model even when data is missing periodically.
 */
(:test)
function testHandlesMeasurementDropouts(oLogger) {
  var fInitialPos = 0.0f;
  var fVelocity = 2.0f;
  var fNoiseStdDev = 1.0f;

  var oFilter = new MyKalmanFilter();
  oFilter.init(fInitialPos, 0.0f, 0);

  var fTotalSqVelErr = 0.0f;

  System.println("t, truePos, noisyPos, estPos, estVel");

  for (var iT = 1; iT <= iTotalTime; iT++) {
    var fTruePos = fInitialPos + fVelocity * iT;

    var bHasMeasurement = (iT % 5 != 0);  // Drop every 5th measurement
    var fNoisyPos = bHasMeasurement ? fTruePos + fGenNoise(fNoiseStdDev) : oFilter.fPosition;

    oFilter.update(fNoisyPos, 0.0f, iT);

    var fVelErr = oFilter.fVelocity - fVelocity;
    fTotalSqVelErr += fVelErr * fVelErr;

    if (iT < 10 || iT > iTotalTime - 10 || !bHasMeasurement) {
      System.println("t=" + iT +
                  ", truePos=" + fTruePos.format("%.2f") +
                  ", noisyPos=" + fNoisyPos.format("%.2f") +
                  ", estPos=" + oFilter.fPosition.format("%.2f") +
                  ", estVel=" + oFilter.fVelocity.format("%.2f"));
    }
  }

  var fRmseVel = fCalcRMSE(fTotalSqVelErr, iTotalTime);
  System.println("Velocity RMSE (with dropouts): " + fRmseVel.format("%.2f"));

  return fRmseVel < fMaxRmseVel;
}

/**
 * Feeds the filter purely random noise (no true position signal).
 * The filter should stabilize around the mean and not diverge.
 * This verifies filter robustness under sensor-only noise.
 */
(:test)
function testNoisyZeroInputStability(oLogger) {
  var fInitialPos = 0.0f;
  var fNoiseStdDev = 2.0f;

  var oFilter = new MyKalmanFilter();
  oFilter.init(fInitialPos, 0.0f, 0);

  var fTotalSqErr = 0.0f;

  System.println("t, noisyPos, estPos");

  for (var iT = 1; iT <= iTotalTime; iT++) {
    var fNoisyPos = fGenNoise(fNoiseStdDev);
    oFilter.update(fNoisyPos, 0.0f, iT);

    var fErr = oFilter.fPosition - fInitialPos;
    fTotalSqErr += fErr * fErr;

    if (iT < 10 || iT > iTotalTime - 10) {
      System.println("t=" + iT +
                  ", noisyPos=" + fNoisyPos.format("%.2f") +
                  ", estPos=" + oFilter.fPosition.format("%.2f"));
    }
  }

  var fRmse = fCalcRMSE(fTotalSqErr, iTotalTime);
  System.println("Final RMSE (Zero Mean Noise): " + fRmse.format("%.2f"));

  return fRmse < fMaxRmsePos;
}
