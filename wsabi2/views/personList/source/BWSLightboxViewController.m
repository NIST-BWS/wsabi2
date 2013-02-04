// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import <AVFoundation/AVFoundation.h>
#import "BWSCaptureController.h"

#import "BWSLightboxViewController.h"

@implementation BWSLightboxViewController

@synthesize imageView = _imageView;

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add drop shadow to image frame
    [[[self imageView] layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[[self imageView] layer] setShadowOffset:CGSizeMake(0, 0)];
    [[[self imageView] layer] setShadowOpacity:1.0];
    [[[self imageView] layer] setShadowRadius:10.0];
    
    // Dim the background
    [[self view] setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self imageView] setImage:[self image]];
    
    // Recenter view
    [[self imageView] setFrame:AVMakeRectWithAspectRatioInsideRect(self.image.size, self.imageView.frame)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[self view] logViewPresented];
    
    // Pinch to zoom setup
    [[self imageView] addGestureRecognizer:[self pinchGestureRecognizer]];
    defaultImageViewFrame = [[self imageView] frame];
    lastImageViewFrame = defaultImageViewFrame;
    [[self imageView] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypePinch];
    [[self imageView] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
    
    // Tap outside image to close
    [[[self view] window] addGestureRecognizer:[self tapGestureRecognizer]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (YES);
}

#pragma mark - Gesture Recognizers

- (IBAction)pinchDetected:(UIPinchGestureRecognizer *)sender
{
    //
    // Pinch to zoom
    //
    CGRect scaledFrame = lastImageViewFrame;

    // Don't zoom in past screen size
    scaledFrame.size.height = MIN(defaultImageViewFrame.size.height, scaledFrame.size.height * [sender scale]);
    scaledFrame.size.width = MIN(defaultImageViewFrame.size.width, scaledFrame.size.width * [sender scale]);
    
    // Keep image centered
    scaledFrame.origin.x = ((defaultImageViewFrame.size.width - scaledFrame.size.width) / 2) + defaultImageViewFrame.origin.x;
    scaledFrame.origin.y = ((defaultImageViewFrame.size.height - scaledFrame.size.height) / 2) + defaultImageViewFrame.origin.y;
    [[self imageView] setFrame:scaledFrame];
    
    if ([sender state] == UIGestureRecognizerStateEnded)
        lastImageViewFrame = scaledFrame;
}

- (IBAction)tapDetected:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        // Get coordinates in the window of tap
        CGPoint location = [sender locationInView:nil];
        
        // Check if tap was within view
        if (![self.imageView pointInside:[self.imageView convertPoint:location fromView:self.view.window] withEvent:nil]) {
            [[[self view] window] removeGestureRecognizer:[self tapGestureRecognizer]];
            
            [self.view logViewDismissedViaTapAtPoint:location];
            [(BWSCaptureController *)[self presentingViewController] didLeaveLightboxMode];
            [self dismissViewControllerAnimated:YES completion:NULL];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return (YES);
}
@end
