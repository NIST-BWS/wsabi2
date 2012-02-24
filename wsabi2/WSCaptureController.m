//
//  WSCaptureController.m
//  wsabi2
//
//  Created by Matt Aronoff on 1/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSCaptureController.h"

@implementation WSCaptureController
@synthesize item;
@synthesize popoverController;
@synthesize modalityButton;
@synthesize deviceButton;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.modalityButton setBackgroundImage:[[UIImage imageNamed:@"BreadcrumbButton"] stretchableImageWithLeftCapWidth:18 topCapHeight:0] forState:UIControlStateNormal];
    [self.modalityButton setTitle:self.item.submodality forState:UIControlStateNormal];
    
    [self.deviceButton setTitle:self.item.deviceConfig.name forState:UIControlStateNormal];
    self.deviceButton.enabled = ![self.item.submodality isEqualToString:[WSModalityMap stringForCaptureType:kCaptureTypeNotSet]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Button Action Methods
-(IBAction)modalityButtonPressed:(id)sender
{
//    [delegate didRequestModalityChangeForItem:self.item];

    //Post a notification to show the modality walkthrough
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:self.item forKey:kDictKeyTargetItem];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowWalkthroughNotification
                                                        object:self
                                                      userInfo:userInfo];

    //close the popover
    [self.popoverController dismissPopoverAnimated:YES];
}

-(IBAction)deviceButtonPressed:(id)sender
{
//    [delegate didRequestDeviceChangeForItem:self.item];

    //Post a notification to show the modality walkthrough starting from device selection.
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.item,kDictKeyTargetItem,[NSNumber numberWithBool:YES],kDictKeyStartFromDevice,nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowWalkthroughNotification
                                                        object:self
                                                      userInfo:userInfo];

    //close the popover
    [self.popoverController dismissPopoverAnimated:YES];
}


@end
