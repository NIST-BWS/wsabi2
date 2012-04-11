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
@synthesize imageView;
@synthesize tempLabel;
@synthesize active;

- (id) init
{
    self = [super init];
    if (self) {
        // Initialization code
        self.tempLabel = [[UILabel alloc] init];
        self.imageView = [[UIImageView alloc] init];
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
        
//        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
//        self.layer.borderWidth = 2;
//        self.layer.cornerRadius = 12;
//        self.layer.shouldRasterize = YES;
//        self.clipsToBounds = YES;

        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        
        view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        view.opaque = NO;

        self.contentView = view;
        
        self.imageView.frame = view.bounds;
        [self.contentView addSubview:self.imageView];
                
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

    self.layer.borderWidth = self.active ? 4.0 : 1.0;
}

-(void) setItem:(WSCDItem *)newItem
{
    if (newItem.data) {
        self.imageView.image = [UIImage imageWithData:newItem.data];
    }

    item = newItem;
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
