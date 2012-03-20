//
//  WSItemGridCell.m
//  wsabi2
//
//  Created by Matt Aronoff on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSItemGridCell.h"

@implementation WSItemGridCell

@synthesize item;
@synthesize tempLabel;
@synthesize active;

- (id) init
{
    self = [super init];
    if (self) {
        // Initialization code
        self.tempLabel = [[UILabel alloc] init];
    }
    return self;

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) layoutSubviews
{
    if (!initialLayoutComplete) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        
        view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        view.opaque = NO;
        view.layer.borderColor = [UIColor lightGrayColor].CGColor;
        view.layer.cornerRadius = 12;
        view.layer.shouldRasterize = YES;

        self.contentView = view;
        
        self.tempLabel.frame = self.bounds;
        self.tempLabel.backgroundColor = [UIColor clearColor];
        self.tempLabel.textColor = [UIColor whiteColor];
        self.tempLabel.textAlignment = UITextAlignmentCenter;
        self.tempLabel.font = [UIFont systemFontOfSize:14];
        self.tempLabel.numberOfLines = 0;
        [self.contentView addSubview:self.tempLabel];
          
        self.deleteButtonIcon = [UIImage imageNamed:@"DeleteRed"];
        self.deleteButtonOffset = CGPointMake(37, 37);
        
        //enable logging for this object.
        //self.touchLoggingEnabled = YES;
        
        initialLayoutComplete = YES;
    }

    self.contentView.layer.borderWidth = self.active ? 4.0 : 1.0;

}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end