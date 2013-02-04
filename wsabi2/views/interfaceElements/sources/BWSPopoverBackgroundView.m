//
//  WSPopoverBackgroundView.m
//  wsabi2
//
//  Created by Matt Aronoff on 5/14/12.
 
//

#import "BWSPopoverBackgroundView.h"

#define ARROW_WIDTH 50.0
#define ARROW_HEIGHT 35.0

#define TOP_CONTENT_INSET 5
#define LEFT_CONTENT_INSET 5
#define BOTTOM_CONTENT_INSET 5
#define RIGHT_CONTENT_INSET 5

//NOTE: Based on code from https://github.com/Scianski/KSCustomUIPopover

@interface BWSPopoverBackgroundView ()
{    
    UIImage *_topArrowImage;
    UIImage *_leftArrowImage;
    UIImage *_rightArrowImage;
    UIImage *_bottomArrowImage;
}

@end

@implementation BWSPopoverBackgroundView

@synthesize arrowOffset = _arrowOffset, arrowDirection = _arrowDirection, popoverBackgroundImageView = _popoverBackgroundImageView, arrowImageView = _arrowImageView;

#pragma mark - Initialization

-(id)initWithFrame:(CGRect)frame 
{    
    if (self = [super initWithFrame:frame])
    {
        _topArrowImage = [UIImage imageNamed:@"popover-arrow-mediumgray"];
        _leftArrowImage = [UIImage imageNamed:@"popover-arrow-mediumgray-270"];
        _bottomArrowImage = [UIImage imageNamed:@"popover-arrow-mediumgray-180"];
        _rightArrowImage = [UIImage imageNamed:@"popover-arrow-mediumgray-90"];
        
        self.arrowImageView = [[UIImageView alloc] init];
        [self addSubview:self.arrowImageView];

        UIImage *popoverBackgroundImage = [[UIImage imageNamed:@"popover-background-mediumgray"] resizableImageWithCapInsets:UIEdgeInsetsMake(49, 46, 49, 45)];
        self.popoverBackgroundImageView = [[UIImageView alloc] initWithImage:popoverBackgroundImage];
        
        self.popoverBackgroundImageView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.popoverBackgroundImageView.layer.shadowOffset = CGSizeMake(0,2);
        self.popoverBackgroundImageView.layer.shadowOpacity = 0.7;
        self.popoverBackgroundImageView.layer.shadowRadius = 8;
        
        [self addSubview:self.popoverBackgroundImageView];
        
    }
    
    return self;
}

// The insets for the content portion of the popover.
+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsMake(TOP_CONTENT_INSET, LEFT_CONTENT_INSET, BOTTOM_CONTENT_INSET, RIGHT_CONTENT_INSET);
}

#pragma mark - Custom setters for updating layout

// Whenever arrow changes direction or position layout subviews will be called in order to update arrow and backgorund frames

-(void) setArrowOffset:(CGFloat)arrowOffset
{
    _arrowOffset = arrowOffset;
    [self setNeedsLayout];
}

-(void) setArrowDirection:(UIPopoverArrowDirection)arrowDirection
{
    _arrowDirection = arrowDirection;
    [self setNeedsLayout];
}

+(CGFloat)arrowHeight{
    return ARROW_HEIGHT;
}

+(CGFloat)arrowBase{
    return ARROW_WIDTH;
}

#pragma mark - Layout subviews

-(void)layoutSubviews
{    
    CGFloat popoverImageOriginX = 0;
    CGFloat popoverImageOriginY = 0;
    
    CGFloat popoverImageWidth = self.bounds.size.width;
    CGFloat popoverImageHeight = self.bounds.size.height;
    
    CGFloat arrowImageOriginX = 0;
    CGFloat arrowImageOriginY = 0;
    
    CGFloat arrowImageWidth = ARROW_WIDTH;
    CGFloat arrowImageHeight = ARROW_HEIGHT;
    
    // Radius value you used to make rounded corners in your popover background image
    CGFloat cornerRadius = 9;
    
    switch (self.arrowDirection) {
            
        case UIPopoverArrowDirectionUp:
            
            popoverImageOriginY = ARROW_HEIGHT - 2;
            popoverImageHeight = self.bounds.size.height - ARROW_HEIGHT;
            
            // Calculating arrow x position using arrow offset, arrow width and popover width
            arrowImageOriginX = roundf((self.bounds.size.width - ARROW_WIDTH) / 2 + self.arrowOffset);
            
            // If arrow image exceeds rounded corner arrow image x postion is adjusted 
            if (arrowImageOriginX + ARROW_WIDTH > self.bounds.size.width - cornerRadius)
            {
                arrowImageOriginX -= cornerRadius;
            }
            
            if (arrowImageOriginX < cornerRadius)
            {
                arrowImageOriginX += cornerRadius;
            }
            
            // Setting arrow image for current arrow direction
            self.arrowImageView.image = _topArrowImage;
            
            break; 
            
        case UIPopoverArrowDirectionDown:
            
            popoverImageHeight = self.bounds.size.height - ARROW_HEIGHT + 2;
            
            arrowImageOriginX = roundf((self.bounds.size.width - ARROW_WIDTH) / 2 + self.arrowOffset);
            
            if (arrowImageOriginX + ARROW_WIDTH > self.bounds.size.width - cornerRadius)
            {
                arrowImageOriginX -= cornerRadius;
            }
            
            if (arrowImageOriginX < cornerRadius)
            {
                arrowImageOriginX += cornerRadius;
            }
            
            arrowImageOriginY = popoverImageHeight - 2;
            
            self.arrowImageView.image = _bottomArrowImage;
            
            break;
            
        case UIPopoverArrowDirectionLeft:
            
            popoverImageOriginX = ARROW_HEIGHT - 2;
            popoverImageWidth = self.bounds.size.width - ARROW_HEIGHT;
            
            arrowImageOriginY = roundf((self.bounds.size.height - ARROW_WIDTH) / 2 + self.arrowOffset);
            
            if (arrowImageOriginY + ARROW_WIDTH > self.bounds.size.height - cornerRadius)
            {
                arrowImageOriginY -= cornerRadius;
            }
            
            if (arrowImageOriginY < cornerRadius)
            {
                arrowImageOriginY += cornerRadius;
            }
            
            arrowImageWidth = ARROW_HEIGHT;
            arrowImageHeight = ARROW_WIDTH;
            
            self.arrowImageView.image = _leftArrowImage;
            
            break;
            
        case UIPopoverArrowDirectionRight:
            
            popoverImageWidth = self.bounds.size.width - ARROW_HEIGHT + 2;
            
            arrowImageOriginX = popoverImageWidth - 2;
            arrowImageOriginY = roundf((self.bounds.size.height - ARROW_WIDTH) / 2 + self.arrowOffset);
            
            if (arrowImageOriginY + ARROW_WIDTH > self.bounds.size.height - cornerRadius)
            {
                arrowImageOriginY -= cornerRadius;
            }
            
            if (arrowImageOriginY < cornerRadius)
            {
                arrowImageOriginY += cornerRadius;
            }
            
            arrowImageWidth = ARROW_HEIGHT;
            arrowImageHeight = ARROW_WIDTH;
            
            self.arrowImageView.image = _rightArrowImage;
            
            break;
            
        default:
            break;
    }
    
    self.popoverBackgroundImageView.frame = CGRectMake(popoverImageOriginX, popoverImageOriginY, popoverImageWidth, popoverImageHeight);
    self.arrowImageView.frame = CGRectMake(arrowImageOriginX, arrowImageOriginY, arrowImageWidth, arrowImageHeight);
}
@end
