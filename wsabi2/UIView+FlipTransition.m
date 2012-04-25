//
//  UIView+FlipTransition.m
//  wsabi2
//
//  Created by Matt Aronoff on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIView+FlipTransition.h"
#import "constants.h"

@implementation UIView (FlipTransition)

//NOTE: Based on https://github.com/sgabello/UIView-FlipTransition
+ (void)flipTransitionFromView:(UIView *)firstView toView:(UIView *)secondView duration:(float)aDuration completion:(void (^)(BOOL finished))completion
{
	firstView.layer.doubleSided = NO;
	secondView.layer.doubleSided = NO;
    
	firstView.layer.zPosition = firstView.layer.bounds.size.width / 2;
	secondView.layer.zPosition = secondView.layer.bounds.size.width / 2;
    
	CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0f/500.0f;
    
	CGAffineTransform translation = CGAffineTransformMakeTranslation(secondView.layer.position.x - firstView.layer.position.x, secondView.layer.position.y - firstView.layer.position.y);
    
	CGAffineTransform scaling = CGAffineTransformMakeScale(secondView.bounds.size.width / firstView.bounds.size.width, secondView.bounds.size.height / firstView.bounds.size.height);
    
	CATransform3D rotation = CATransform3DRotate(transform, -0.999 * M_PI, 0.0f, 1.0f, 0.0f);
    
	CATransform3D firstViewTransform = CATransform3DConcat(rotation, CATransform3DMakeAffineTransform(CGAffineTransformConcat(scaling, translation)));
    
	CATransform3D secondViewTransform = CATransform3DConcat(CATransform3DInvert(rotation), CATransform3DMakeAffineTransform(CGAffineTransformConcat(CGAffineTransformInvert(scaling), CGAffineTransformInvert(translation))));
    
	if (secondView.hidden)
	{
		secondView.layer.transform = secondViewTransform;
	}
    
	firstView.hidden = NO;
	secondView.hidden = NO;
    
	CATransform3D firstToTransform = firstViewTransform;
    CATransform3D secondToTransform = CATransform3DIdentity;
	BOOL firstViewWillHide = YES;
    
    if (CATransform3DIsIdentity(secondView.layer.transform))
    {
		firstToTransform = CATransform3DIdentity;
        secondToTransform = secondViewTransform;
		firstViewWillHide = NO;
    }
    
    [UIView animateWithDuration:aDuration
                     animations:^(void){
                         firstView.layer.transform = firstToTransform;
                         secondView.layer.transform = secondToTransform;
                     }
                     completion:^(BOOL finished) {
						 firstView.hidden = firstViewWillHide;
						 secondView.hidden = !firstView.hidden;
						 if (completion)
							 completion(finished);
					 }];
}

////Based on code from http://stackoverflow.com/questions/2644797/darkening-uiview-while-flipping-over-using-uiviewanimationtransitionflipfromright
//- (void)flipFromView:(UIView*)viewOne toView:(UIView*)viewTwo
//{
//    viewOne.hidden = YES;
//    
//    CATransform3D matrix = CATransform3DMakeRotation (M_PI / 2, 0.0, 1.0, 0.0);
//    CATransform3D matrix2 = CATransform3DMakeRotation (-M_PI / 2 , 0.0, 1.0, 0.0);
//    matrix = CATransform3DScale (matrix, 1.0, 0.975, 1.0);
//    matrix.m34 = 1.0 / -500;
//    
//    matrix2 = CATransform3DScale (matrix2, 1.0, 0.975, 1.0);
//    matrix2.m34 = 1.0 / -500;
//    
//    viewOne.layer.transform = matrix2;
//    
//    [UIView animateWithDuration:kFlipAnimationDuration
//                          delay:0 options:UIViewAnimationCurveEaseIn
//                     animations:^{ 
//                         viewTwo.layer.transform = matrix;
//                     }
//                     completion:^(BOOL completed) {
//                         viewOne.hidden = NO;
//                         viewTwo.hidden = YES;
//                         
//                         CATransform3D matrix = CATransform3DMakeRotation (2 * M_PI, 0.0, 1.0, 0.0);
//                         
//                         matrix = CATransform3DScale (matrix, 1.0, 1.0, 1.0);
//                         int indexOfTwo = [self.subviews indexOfObject:viewTwo];
//                         int indexOfOne = [self.subviews indexOfObject:viewOne];
//
//                         [UIView animateWithDuration:kFlipAnimationDuration
//                                               delay:0 options:UIViewAnimationCurveEaseOut
//                                          animations:^{ 
//                                              viewOne.layer.transform = matrix;
//                                          }
//                                          completion:^(BOOL completed) {
//                                              [self exchangeSubviewAtIndex:indexOfTwo withSubviewAtIndex:indexOfOne];
//                                          }
//                          ];
//                         
//                     }
//     ];
//    
//}

@end
