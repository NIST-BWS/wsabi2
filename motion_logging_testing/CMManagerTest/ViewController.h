//
//  ViewController.h
//  CMManagerTest
//
//  Created by Greg Fiumara on 10/4/12.
//  Copyright (c) 2012 Greg Fiumara. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WSMotionLogger.h"
#import "WSMotionLoggerDelegate.h"

@interface ViewController : UIViewController <WSMotionLoggerDelegate>

@property(nonatomic, strong) WSMotionLogger *motionLogger;
@property (weak, nonatomic) IBOutlet UILabel *accelerometerXLabel;
@property (weak, nonatomic) IBOutlet UILabel *accelerometerYLabel;
@property (weak, nonatomic) IBOutlet UILabel *accelerometerZLabel;
@property (weak, nonatomic) IBOutlet UILabel *gyroscopeXLabel;
@property (weak, nonatomic) IBOutlet UILabel *gyroscopeYLabel;
@property (weak, nonatomic) IBOutlet UILabel *gyroscopeZLabel;
@property (weak, nonatomic) IBOutlet UILabel *xAxisAngleLabel;
@property (weak, nonatomic) IBOutlet UILabel *yAxisAngleLabel;
@property (weak, nonatomic) IBOutlet UILabel *zAxisAngleLabel;

@end
