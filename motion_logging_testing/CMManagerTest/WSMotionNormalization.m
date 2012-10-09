//
//  WSMotionNormalization.m
//  CMManagerTest
//
//  Created by Greg Fiumara on 10/9/12.
//  Copyright (c) 2012 Greg Fiumara. All rights reserved.
//

#import "WSMotionNormalization.h"

@interface WSMotionNormalization()

+ (float)normalizeValue:(float)value oldMin:(float)oldMin oldMax:(float)oldMax newMin:(float)newMin newMax:(float)newMax;

@end

@implementation WSMotionNormalization

+ (float)xAxisAngleFromAccelerometerData:(CMAccelerometerData *)accelerometerData
{
    // TODO: "Calibrate" to provide for the real accelerometer range
    return ([self normalizeValue:accelerometerData.acceleration.x oldMin:-1.0 oldMax:1.0 newMin:-90.0 newMax:90.0]);
    
    // 0 == left and right side level
    // -90 == device perpendicular to floor, left side down
    // 90 == device perpendicular to floor, right side down
}

+ (float)yAxisAngleFromAccelerometerData:(CMAccelerometerData *)accelerometerData
{
    // TODO: "Calibrate" to provide for the real accelerometer range
    return ([self normalizeValue:accelerometerData.acceleration.y oldMin:-1.0 oldMax:1.0 newMin:-90.0 newMax:90.0]);
    
    // 0 == top and bottom side level
    // -90 == bottom side down
    // 90 == top side down
}

+ (float)zAxisAngleFromAccelerometerData:(CMAccelerometerData *)accelerometerData
{
    // TODO: "Calibrate" to provide for the real accelerometer range
    return ([self normalizeValue:accelerometerData.acceleration.z oldMin:-1.0 oldMax:1.0 newMin:0.0 newMax:180.0]);
    
    // 0 == device parallel to floor, screen facing up
    // 90 == device perpendicular to floor
    // 180 == device parallel to floor, screen facing down
}

+ (float)normalizeValue:(float)value oldMin:(float)oldMin oldMax:(float)oldMax newMin:(float)newMin newMax:(float)newMax
{
    float scaleDenominator = oldMax - oldMin;
    if (scaleDenominator == 0)
        return (nanf(""));
    return (newMin + ((value - oldMin) * ((newMax - newMin) / scaleDenominator)));
}
            
@end
