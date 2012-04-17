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
@synthesize shadowView;
@synthesize glossView;
@synthesize active;
@synthesize selected;

- (id) init
{
    self = [super init];
    if (self) {
        // Initialization code
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
        //self.layer.cornerRadius = kItemCellCornerRadius;
//        self.layer.shouldRasterize = YES;
//        self.clipsToBounds = YES;

        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        
        //view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        view.opaque = NO;

        self.contentView = view;
        
        self.shadowView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"item-cell-shadow-normal"] stretchableImageWithLeftCapWidth:34 topCapHeight:34]];
        self.shadowView.frame = CGRectInset(view.bounds, -12, -12); //make this bigger than the cell.
        [self.contentView addSubview:self.shadowView];
        
        self.imageView.frame = view.bounds;
        [self.contentView addSubview:self.imageView];
        
//        self.glossView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gloss_114"]];
//        self.glossView.alpha = 1;
//        [self.contentView addSubview:self.glossView];
        
        self.deleteButtonIcon = [UIImage imageNamed:@"DeleteRed"];
        self.deleteButtonOffset = CGPointMake(37, 37);
        
        //enable logging for this object.
        //self.touchLoggingEnabled = YES;
        
        initialLayoutComplete = YES;
    }

//    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    self.layer.borderWidth = self.active ? 4.0 : 1.0;
}

-(void) setItem:(WSCDItem *)newItem
{
    if (newItem.data) {
        self.imageView.image = [UIImage imageWithData:newItem.thumbnail];
    }
    else {
        self.imageView.image = nil;
    }

    item = newItem;
}

-(void) setSelected:(BOOL)sel
{
    selected = sel;
    
    if (selected) {
        self.shadowView.image = [[UIImage imageNamed:@"item-cell-shadow-selected"] stretchableImageWithLeftCapWidth:34 topCapHeight:34];
    }
    else {
        self.shadowView.image = [[UIImage imageNamed:@"item-cell-shadow-normal"] stretchableImageWithLeftCapWidth:34 topCapHeight:34];
    }
}
//Override this method from GMGridViewCell to make sure we don't shake when editing.
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [super shakeStatus:NO];
}

@end
