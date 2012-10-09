//
//  WSMotionNormalization.h
//  CMManagerTest
//
//  Created by Greg Fiumara on 10/9/12.
//  Copyright (c) 2012 Greg Fiumara. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <CoreMotion/CoreMotion.h>

@interface WSMotionNormalization : NSObject

+ (float)yAxisAngleFromAccelerometerData:(CMAccelerometerData *)accelerometerData;
+ (float)zAxisAngleFromAccelerometerData:(CMAccelerometerData *)accelerometerData;
+ (float)xAxisAngleFromAccelerometerData:(CMAccelerometerData *)accelerometerData;

@end
