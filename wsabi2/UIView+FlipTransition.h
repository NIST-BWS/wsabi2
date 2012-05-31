//
//  UIView+FlipTransition.h
//  wsabi2
//
//  Created by Matt Aronoff on 4/24/12.
 
//

#import <UIKit/UIKit.h>

@interface UIView (FlipTransition)

+ (void)flipTransitionFromView:(UIView *)firstView toView:(UIView *)secondView duration:(float)aDuration completion:(void (^)(BOOL finished))completion;
@end
