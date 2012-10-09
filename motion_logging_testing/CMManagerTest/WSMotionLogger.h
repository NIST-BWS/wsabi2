//
//  WSMotionLogger.h
//  CMManagerTest
//
//  Created by Greg Fiumara on 10/4/12.
//  Copyright (c) 2012 Greg Fiumara. All rights reserved.
//

#import "WSMotionLoggerDelegate.h"

#import <Foundation/Foundation.h>

#import <CoreMotion/CoreMotion.h>

// How often the motion updates should be polled
static const NSTimeInterval kMotionLoggerMotionUpdateInterval = 1.0 / 60.0;
// How often the accelerometer updates should be polled
static const NSTimeInterval kMotionLoggerAccelerometerUpdateInterval = 1.0 / 60.0;
// How often the gyroscope updates should be polled
static const NSTimeInterval kMotionLoggerGyroscopeUpdateInterval = 1.0 / 60.0;

// Minimum number of decimal places for motion
static const NSUInteger kWSMotionLoggerMinMotionSensitivity = 0;
// Default number of decimal places for motion
static const NSUInteger kWSMotionLoggerDefaultMotionSensitivity = 2;
// Maximum number of decimal places for motion
static const NSUInteger kWSMotionLoggerMaxMotionSensitivity = 6;

// Minimum number of decimal places for accelerometer
static const NSUInteger kWSMotionLoggerMinAccelerometerSensitivity = 0;
// Default number of decimal places for accelerometer
static const NSUInteger kWSMotionLoggerDefaultAccelerometerSensitivity = 2;
// Maximum number of decimal places for accelerometer
static const NSUInteger kWSMotionLoggerMaxAccelerometerSensitivity = 6;

// Minimum number of decimal places for gyroscope
static const NSUInteger kWSMotionLoggerMinGyroscopeSensitivity = 0;
// Default number of decimal places for gyroscope
static const NSUInteger kWSMotionLoggerDefaultGyroscopeSensitivity = 2;
// Maximum number of decimal places for gyroscope
static const NSUInteger kWSMotionLoggerMaxGyroscopeSensitivity = 6;

/// A convenience wrapper around CMMotionmanager to obtain device motion
/// changes for logging
@interface WSMotionLogger : NSObject

/// Delegate who will be notified when measurement changes occur.
@property(nonatomic, strong) id<WSMotionLoggerDelegate> delegate;

/// The number of decimal places of change that must take place in acceleration
/// measurement to trigger an update (movement).
@property(nonatomic, assign) NSUInteger accelerometerSensitivity;
/// The number of decimal places of change that must take place in gyroscope
/// measurement to trigger an update (rotation).
@property(nonatomic, assign) NSUInteger gyroscopeSensitivity;
/// The number of decimal places of change that must take place in motion
/// measurement to trigger an update (movement + rotation + position).
@property(nonatomic, assign) NSUInteger motionSensitivity;

/// @brief
/// Begin measuring information on all supported sensors.
///
/// @return
/// YES if all sensors could be started, NO otherwise.
- (BOOL)startLoggingAllMotionUpdates;
/// @brief
/// Stop gathering information for all supported sensors.
- (void)stopLoggingAllMotionUpdates;

/// @brief
/// Begin gathering information from the accelerometer.
///
/// @return
/// YES if accelerometer measurement sensing could be started, NO otherwise.
- (BOOL)startLoggingAccelerometerUpdates;
/// @brief
/// Stop gathering information from the accelerometer.
- (void)stopLoggingAccelerometerUpdates;

/// @brief
/// Begin gathering information from the gyroscope.
///
/// @return
/// YES if gyroscope measurement sensing could be started, NO otherwise.
- (BOOL)startLoggingGyroscopeUpdates;
/// @brief
/// Stop gathering information from the gyroscope.
- (void)stopLoggingGyroscopeUpdates;

/// @brief
/// Begin gathering motion information.
/// @details
/// Motion information is derived data from the accelerometer and
/// the gyroscope and/or magnetometer.
///
/// @return
/// YES if motion measurement sensing could be started, NO otherwise.
- (BOOL)startLoggingMotionUpdates;
/// @brief
/// Stop gathering information from the gyroscope.
- (void)stopLoggingMotionUpdates;

/// @brief
/// Convert radian value to degrees.
///
/// @param radians
/// Radian value.
///
/// @return
/// Value of radians in degrees.
+ (double)degreeValue:(double)radians;

@end
