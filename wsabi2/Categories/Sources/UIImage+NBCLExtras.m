// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import "UIImage+NBCLExtras.h"


@implementation UIImage (NBCLExtras)
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)targetSize {
    //If scaleFactor is not touched, no scaling will occur      
    CGFloat scaleFactor = 1.0;
    
    //Deciding which factor to use to scale the image (factor = targetSize / imageSize)
    if (image.size.width > targetSize.width || image.size.height > targetSize.height)
        if (!((scaleFactor = (targetSize.width / image.size.width)) > (targetSize.height / image.size.height))) //scale to fit width, or
            scaleFactor = targetSize.height / image.size.height; // scale to fit heigth.
    
    float hfactor = image.size.width / targetSize.width;
    float vfactor = image.size.height / targetSize.height;
    
    float factor = fmax(hfactor, vfactor);
    
    // Divide the size by the greater of the vertical or horizontal shrinkage factor
    float newWidth = image.size.width / factor;
    float newHeight = image.size.height / factor;
    
    // Then figure out if you need to offset it to center vertically or horizontally
    float leftOffset = (targetSize.width - newWidth) / 2;
    float topOffset = (targetSize.height - newHeight) / 2;
    
    UIGraphicsBeginImageContext(targetSize); 
    
    //Creating the rect where the scaled image is drawn in
    CGRect rect = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
    
    //Draw the image into the rect
    [image drawInRect:rect];
    
    //Saving the image, ending image context
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

+ (UIImage *)imageWithString:(NSString *)string font:(UIFont *)font
{
    CGSize frameSize = [string sizeWithFont:font];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frameSize.width, frameSize.height)];
    [label setFont:font];
    [label setOpaque:NO];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:string];
    
    UIGraphicsBeginImageContextWithOptions(frameSize, NO, 0.0);
    [label.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *retVal = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return (retVal);
}

@end
