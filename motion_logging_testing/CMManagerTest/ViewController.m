//
//  ViewController.m
//  CMManagerTest
//
//  Created by Greg Fiumara on 10/4/12.
//  Copyright (c) 2012 Greg Fiumara. All rights reserved.
//

#import "ViewController.h"
#import "WSMotionNormalization.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize motionLogger;
@synthesize accelerometerXLabel;
@synthesize accelerometerYLabel;
@synthesize accelerometerZLabel;
@synthesize gyroscopeXLabel;
@synthesize gyroscopeYLabel;
@synthesize gyroscopeZLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setMotionLogger:[[WSMotionLogger alloc] init]];
    [[self motionLogger] setDelegate:self];
    [[self motionLogger] startLoggingAllMotionUpdates];
    
    [[self motionLogger] setAccelerometerSensitivity:1];
    [[self motionLogger] setGyroscopeSensitivity:1];
    [[self motionLogger] setMotionSensitivity:1];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[self motionLogger] stopLoggingAllMotionUpdates];
}

- (void)accelerometerWasUpdatedWithAccelerometerData:(CMAccelerometerData *)accelerometerData error:(NSError *)error
{
    if (error != NULL)
        NSAssert(NO == YES, [error localizedDescription]);
    
    NSString *formatString = [NSString stringWithFormat:@"%%.%uf", [[self motionLogger] accelerometerSensitivity]];
    [[self accelerometerXLabel] setText:[NSString stringWithFormat:formatString, [accelerometerData acceleration].x]];
    [[self accelerometerYLabel] setText:[NSString stringWithFormat:formatString, [accelerometerData acceleration].y]];
    [[self accelerometerZLabel] setText:[NSString stringWithFormat:formatString, [accelerometerData acceleration].z]];
    
    [[self xAxisAngleLabel] setText:[NSString stringWithFormat:formatString, [WSMotionNormalization xAxisAngleFromAccelerometerData:accelerometerData]]];
    [[self yAxisAngleLabel] setText:[NSString stringWithFormat:formatString, [WSMotionNormalization yAxisAngleFromAccelerometerData:accelerometerData]]];
    [[self zAxisAngleLabel] setText:[NSString stringWithFormat:formatString, [WSMotionNormalization zAxisAngleFromAccelerometerData:accelerometerData]]];
}

- (void)gyroscopeWasUpdatedWithGyroscopeData:(CMGyroData *)gyroscopeData error:(NSError *)error
{
    if (error != NULL)
        NSAssert(NO == YES, [error localizedDescription]);
    
    NSString *formatString = [NSString stringWithFormat:@"%%.%uf", [[self motionLogger] gyroscopeSensitivity]];
    [[self gyroscopeXLabel] setText:[NSString stringWithFormat:formatString, [gyroscopeData rotationRate].x]];
    [[self gyroscopeYLabel] setText:[NSString stringWithFormat:formatString, [gyroscopeData rotationRate].y]];
    [[self gyroscopeZLabel] setText:[NSString stringWithFormat:formatString, [gyroscopeData rotationRate].z]];
}

- (void)motionWasUpdatedWithMotionData:(CMDeviceMotion *)motionData error:(NSError *)error
{
    if (error != NULL)
        NSAssert(NO == YES, [error localizedDescription]);
    
    NSString *formatString = [NSString stringWithFormat:@"%%.%uf", [[self motionLogger] motionSensitivity]];
    [[self yawLabel] setText:[NSString stringWithFormat:formatString, [WSMotionLogger degreeValue:[motionData attitude].yaw]]];
    [[self pitchLabel] setText:[NSString stringWithFormat:formatString, [WSMotionLogger degreeValue:[motionData attitude].pitch]]];
    [[self rollLabel] setText:[NSString stringWithFormat:formatString, [WSMotionLogger degreeValue:[motionData attitude].roll]]];
}

- (void)viewDidUnload {
    [self setYawLabel:nil];
    [self setPitchLabel:nil];
    [self setRollLabel:nil];
    [super viewDidUnload];
}
@end
