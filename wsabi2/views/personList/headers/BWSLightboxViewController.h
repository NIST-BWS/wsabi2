//
//  WSLightboxViewController.h
//  wsabi2
//
//  Created by Greg Fiumara on 12/28/12.
//
//

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
