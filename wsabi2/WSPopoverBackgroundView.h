//
//  WSPopoverBackgroundView.h
//  wsabi2
//
//  Created by Matt Aronoff on 5/14/12.
 
//

#import <UIKit/UIKit.h>

//NOTE: Based on code from https://github.com/Scianski/KSCustomUIPopover

@interface WSPopoverBackgroundView : UIPopoverBackgroundView 
{    
    CGFloat                     _arrowOffset;
    UIPopoverArrowDirection     _arrowDirection;
    UIImageView                *_arrowImageView;
    UIImageView                *_popoverBackgroundImageView;   
}

@property (nonatomic, readwrite)            CGFloat                  arrowOffset;
@property (nonatomic, readwrite)            UIPopoverArrowDirection  arrowDirection;
@property (nonatomic, readwrite, strong)    UIImageView             *arrowImageView;
@property (nonatomic, readwrite, strong)    UIImageView             *popoverBackgroundImageView;

+ (CGFloat)arrowHeight;
+ (CGFloat)arrowBase;
+ (UIEdgeInsets)contentViewInsets;

@end
