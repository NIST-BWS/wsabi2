// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import <UIKit/UIKit.h>

/// ViewController for displaying biometric captures in full screen.
@interface BWSLightboxViewController : UIViewController
{
    CGRect defaultImageViewFrame;
    CGRect lastImageViewFrame;
}

/// ImageView displaying the image
@property (weak, nonatomic, readonly) IBOutlet UIImageView *imageView;
/// The image data being displayed
@property (strong, nonatomic) UIImage *image;
/// Pinch to zoom gesture recognizer
@property (strong, nonatomic) IBOutlet UIPinchGestureRecognizer *pinchGestureRecognizer;
/// Tap outside to close gesture recognizer
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;

/// Pinch detected on imageView
- (IBAction)pinchDetected:(UIPinchGestureRecognizer *)sender;
/// Tap detected on UIWindow
- (IBAction)tapDetected:(UITapGestureRecognizer *)sender;

@end
