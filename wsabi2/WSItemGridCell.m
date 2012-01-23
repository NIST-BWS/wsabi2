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
@synthesize deleteButton;
@synthesize delegate;

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

        self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.deleteButton.bounds = CGRectMake(0, 0, 44, 44);
        [self.deleteButton setBackgroundImage:[UIImage imageNamed:@"Delete"] forState:UIControlStateNormal];
        self.deleteButton.center = CGPointMake(self.contentView.bounds.size.width/2.0, self.contentView.bounds.size.height/2.0);
        self.deleteButton.hidden = YES;
        [self.contentView addSubview:self.deleteButton];
        
        //add an action to the delete button
        [self.deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        initialLayoutComplete = YES;
    }
}

//NOTE: Always animate the delete button.
-(void) setEditing:(BOOL)editing
{
    [super setEditing:editing];
        
     if (self.editing) {
         //add the delete button
         NSLog(@"Editing cell %@ now",self);
         self.deleteButton.alpha = 0.0;
         self.deleteButton.hidden = NO;
         [UIView animateWithDuration:kMediumFadeAnimationDuration
                          animations:^{
                              self.deleteButton.alpha = 1.0;
                          } 
                          completion:^(BOOL completed) {
                              
                          }];

     }
     else {
         //remove the delete button
         NSLog(@"No longer editing cell %@",self);
          [UIView animateWithDuration:kMediumFadeAnimationDuration
                          animations:^{
                              self.deleteButton.alpha = 0.0;
                          } 
                          completion:^(BOOL completed) {
                              self.deleteButton.hidden = YES;

                          }];

     }


}

-(void) deleteButtonPressed:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete Item"
                                                    otherButtonTitles:nil];
    [actionSheet showFromRect:self.bounds inView:self animated:YES];
}

#pragma mark - Action Sheet Delegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        //just fire the delegate
        [delegate didRequestItemDeletion:self.item];
        
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
