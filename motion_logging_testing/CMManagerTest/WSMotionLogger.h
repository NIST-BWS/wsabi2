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

// How often the accelerometer updates should be polled
static const NSTimeInterval kGyroLoggerAccelerometerUpdateInterval = 1.0 / 60.0;
// How often the gyroscope updates should be polled
static const NSTimeInterval kGyroLoggerGyroscopeUpdateInterval = 1.0 / 60.0;

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
static const NSUInteger kWSMotionLoggerMaxGyroscopeSensitivity = 2;

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
/// Begin gathering information for accelerometer.
///
/// @return
/// YES if accelerometer measurement sensing could be started, NO otherwise.
- (BOOL)startLoggingAccelerometerUpdates;
/// @brief
/// Stop gathering information from the accelerometer.
- (void)stopLoggingAccelerometerUpdates;

/// @brief
/// Begin gathering information for gyroscope.
///
/// @return
/// YES if gyroscope measurement sensing could be started, NO otherwise.
- (BOOL)startLoggingGyroscopeUpdates;
/// @brief
/// Stop gathering information from the gyroscope.
- (void)stopLoggingGyroscopeUpdates;

@end
