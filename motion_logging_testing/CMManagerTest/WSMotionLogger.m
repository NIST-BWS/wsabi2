//
//  WSMotionLogger.m
//  CMManagerTest
//
//  Created by Greg Fiumara on 10/4/12.
//  Copyright (c) 2012 Greg Fiumara. All rights reserved.
//

#import "WSMotionLogger.h"

@interface WSMotionLogger()

+ (void)checkForExistingInstantiation;

@property(nonatomic, strong) CMMotionManager *motionManager;
@property(nonatomic, strong) NSOperationQueue *accelerometerQueue;
@property(nonatomic, strong) NSOperationQueue *gyroscopeQueue;
@property(nonatomic, strong) NSOperationQueue *motionQueue;

@end

@implementation WSMotionLogger

@synthesize motionManager;
@synthesize accelerometerQueue;
@synthesize gyroscopeQueue;
@synthesize delegate;
@synthesize accelerometerSensitivity = _accelerometerSensitivity;
@synthesize gyroscopeSensitivity = _gyroscopeSensitivity;
@synthesize motionSensitivity = _motionSensitivity;

#pragma mark -

- (id)init
{
    // Really don't want to have more than one instance, but a singleton
    // instance doesn't quite make sense.  Instead, enforce proper programming.
    [WSMotionLogger checkForExistingInstantiation];
    
    self = [super init];
    if (self != nil) {
        [self setMotionManager:[[CMMotionManager alloc] init]];
        
        [self setAccelerometerSensitivity:kWSMotionLoggerDefaultAccelerometerSensitivity];
        [self setGyroscopeSensitivity:kWSMotionLoggerDefaultGyroscopeSensitivity];
    }
    
    return (self);
}

#pragma mark - Start/Stop Logging

- (BOOL)startLoggingAllMotionUpdates
{
    if ([self startLoggingAccelerometerUpdates] == NO)
        return (NO);
        
    if ([self startLoggingGyroscopeUpdates] == NO) {
        [self stopLoggingAccelerometerUpdates];
        return (NO);
    }
    
    if ([self startLoggingMotionUpdates] == NO) {
        [self stopLoggingAccelerometerUpdates];
        [self stopLoggingGyroscopeUpdates];
        return (NO);
    }
    
    return (YES);
}

- (void)stopLoggingAllMotionUpdates
{
    [self stopLoggingAccelerometerUpdates];
    [self stopLoggingGyroscopeUpdates];
    [self stopLoggingMotionUpdates];
}

- (BOOL)startLoggingAccelerometerUpdates
{
    if ([[self motionManager] isAccelerometerAvailable] == NO)
        return (NO);
    
    [self setAccelerometerQueue:[[NSOperationQueue alloc] init]];
    [[self motionManager] setAccelerometerUpdateInterval:kMotionLoggerAccelerometerUpdateInterval];
    
//    [[self motionManager] startAccelerometerUpdatesToQueue:[self accelerometerQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
    [[self motionManager] startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        // Values that x, y, and z could never be
        static double lastX = -42;
        static double lastY = -42;
        static double lastZ = -42;
                
        if (error == NULL) {
            // Only call delegate if the change is of the proper sensitivity
            double threshold = (1.0 / pow(10.0, [self accelerometerSensitivity]));
            
            if ((fabs(lastX - [accelerometerData acceleration].x) >= threshold) ||
                (fabs(lastY - [accelerometerData acceleration].y) >= threshold) ||
                (fabs(lastZ - [accelerometerData acceleration].z) >= threshold)) {
                [[self delegate] accelerometerWasUpdatedWithAccelerometerData:accelerometerData error:error];
                
                lastX = [accelerometerData acceleration].x;
                lastY = [accelerometerData acceleration].y;
                lastZ = [accelerometerData acceleration].z;
            }
        } else
            [[self delegate] accelerometerWasUpdatedWithAccelerometerData:accelerometerData error:error];
    }];
    
    return (YES);
}

- (void)stopLoggingAccelerometerUpdates
{
    [[self motionManager] stopAccelerometerUpdates];
}

- (BOOL)startLoggingGyroscopeUpdates
{
    if ([[self motionManager] isGyroAvailable] == NO)
        return (NO);
    
    [self setGyroscopeQueue:[[NSOperationQueue alloc] init]];
    [[self motionManager] setGyroUpdateInterval:kMotionLoggerGyroscopeUpdateInterval];

//    [[self motionManager] startGyroUpdatesToQueue:[self gyroscopeQueue] withHandler:^(CMGyroData *gyroscopeData, NSError *error) {
    [[self motionManager] startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData *gyroscopeData, NSError *error) {
        // Values that x, y, and z could never be
        static double lastX = -42;
        static double lastY = -42;
        static double lastZ = -42;
        
        if (error == NULL) {
            // Only call delegate if the change is of the proper sensitivity
            double threshold = (1.0 / pow(10.0, [self gyroscopeSensitivity]));
            
            if ((fabs(lastX - [gyroscopeData rotationRate].x) >= threshold) ||
                (fabs(lastY - [gyroscopeData rotationRate].y) >= threshold) ||
                (fabs(lastZ - [gyroscopeData rotationRate].z) >= threshold)) {
                [[self delegate] gyroscopeWasUpdatedWithGyroscopeData:gyroscopeData error:error];
                
                lastX = [gyroscopeData rotationRate].x;
                lastY = [gyroscopeData rotationRate].y;
                lastZ = [gyroscopeData rotationRate].z;
            }
        } else
            [[self delegate] gyroscopeWasUpdatedWithGyroscopeData:gyroscopeData error:error];
    }];
    
    return (YES);
}

- (void)stopLoggingGyroscopeUpdates
{
    [[self motionManager] stopGyroUpdates];
}

- (BOOL)startLoggingMotionUpdates
{
    if ([[self motionManager] isDeviceMotionAvailable] == NO)
        return (NO);
    
    [self setMotionQueue:[[NSOperationQueue alloc] init]];
    [[self motionManager] setDeviceMotionUpdateInterval:kMotionLoggerGyroscopeUpdateInterval];
    
//    [[self motionManager] startDeviceMotionUpdatesToQueue:[self motionQueue] withHandler:^(CMDeviceMotion *motionData, NSError *error) {
    [[self motionManager] startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motionData, NSError *error) {
        // Values that x, y, and z could never be
        static double lastYaw = -4000;
        static double lastPitch = -4000;
        static double lastRoll = -4000;
        
        if (error == NULL) {
            // Only call delegate if the change is of the proper sensitivity
            double threshold = (1.0 / pow(10.0, [self motionSensitivity]));
            
            if ((fabs(lastYaw - [motionData attitude].yaw) >= threshold) ||
                (fabs(lastPitch - [motionData attitude].pitch) >= threshold) ||
                (fabs(lastRoll - [motionData attitude].roll) >= threshold)) {
                [[self delegate] motionWasUpdatedWithMotionData:motionData error:error];
                
                lastYaw = [motionData attitude].yaw;
                lastPitch = [motionData attitude].pitch;
                lastRoll = [motionData attitude].roll;
            }
        } else
            [[self delegate] motionWasUpdatedWithMotionData:motionData error:error];
    }];
    
    return (YES);

}

- (void)stopLoggingMotionUpdates
{
    [[self motionManager] stopDeviceMotionUpdates];
}

#pragma mark - Setter overloads

- (void)setAccelerometerSensitivity:(NSUInteger)accelerometerSensitivity
{
    if ((accelerometerSensitivity < kWSMotionLoggerMinAccelerometerSensitivity) ||
        (accelerometerSensitivity > kWSMotionLoggerMaxAccelerometerSensitivity)) {
        NSLog(@"accelerometerSensitivity must be between %u and %u.", kWSMotionLoggerMinAccelerometerSensitivity, kWSMotionLoggerMaxAccelerometerSensitivity);
        return;
    }

    _accelerometerSensitivity = accelerometerSensitivity;
}

- (void)setGyroscopeSensitivity:(NSUInteger)gyroscopeSensitivity
{
    if ((gyroscopeSensitivity < kWSMotionLoggerMinGyroscopeSensitivity) ||
        (gyroscopeSensitivity > kWSMotionLoggerMaxGyroscopeSensitivity)) {
        NSLog(@"gyroscopeSensitivity must be between %u and %u.", kWSMotionLoggerMinGyroscopeSensitivity, kWSMotionLoggerMaxGyroscopeSensitivity);
        return;
    }
    
    _gyroscopeSensitivity = gyroscopeSensitivity;
}

- (void)setMotionSensitivity:(NSUInteger)motionSensitivity
{
    if ((motionSensitivity < kWSMotionLoggerMinMotionSensitivity) ||
        (motionSensitivity > kWSMotionLoggerMaxMotionSensitivity)) {
        NSLog(@"motionSensitivity must be between %u and %u.", kWSMotionLoggerMinMotionSensitivity, kWSMotionLoggerMaxMotionSensitivity);
        return;
    }
    
    _motionSensitivity = motionSensitivity;
}


#pragma mark - Static Helpers

+ (double)degreeValue:(double)radians
{
    return ((radians * 180) / M_PI);
}

#pragma mark - PsuedoSingleton Category

+ (void)checkForExistingInstantiation
{
    static BOOL instantiated = NO;
    NSAssert(instantiated == NO, @"You may only have one WSMotionLogger instance per project.");
    instantiated = YES;
}

@end
