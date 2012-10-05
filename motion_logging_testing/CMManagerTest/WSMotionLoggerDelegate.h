//
//  WSMotionLoggerDelegate.h
//  CMManagerTest
//
//  Created by Greg Fiumara on 10/4/12.
//  Copyright (c) 2012 Greg Fiumara. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreMotion/CoreMotion.h>

/// Delegate handling messages from a WSMotionLogger
@protocol WSMotionLoggerDelegate <NSObject>

@optional

/// @brief
/// Called when an update was received from the accelerometer.
///
/// @param accelerometerData
/// Latest update received from the accelerometer.
/// @param error
/// Not NULL on error.
- (void)accelerometerWasUpdatedWithAccelerometerData:(CMAccelerometerData *)accelerometerData error:(NSError *)error;

/// @brief
/// Called when an update was received from the gyroscope.
///
/// @param gyroscopeData
/// Latest update received from the gyroscope.
/// @param error
/// Not NULL on error.
- (void)gyroscopeWasUpdatedWithGyroscopeData:(CMGyroData *)gyroscopeData error:(NSError *)error;

@end
