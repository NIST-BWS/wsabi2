//
//  WSItemGridCell.m
//  wsabi2
//
//  Created by Matt Aronoff on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSItemGridCell.h"

@implementation WSItemGridCell

@synthesize deleteButton;

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
        
        self.backgroundView.backgroundColor = [UIColor clearColor];
        
        self.contentView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        self.contentView.opaque = NO;
        self.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.contentView.layer.borderWidth = 4.0;
        self.contentView.layer.cornerRadius = 12;

        initialLayoutComplete = YES;
    }
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (self.editing) {
        //add the delete button
    }
    else {
        //remove the delete button
    }

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
