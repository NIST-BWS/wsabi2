//
//  ViewController.m
//  CMManagerTest
//
//  Created by Greg Fiumara on 10/4/12.
//  Copyright (c) 2012 Greg Fiumara. All rights reserved.
//

#import "ViewController.h"


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

@end
