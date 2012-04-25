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
@synthesize annotationView;
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

#pragma mark - Internal convenience methods
-(BOOL) hasAnnotationOrNotes
{
    if (self.item.notes && ![self.item.notes isEqualToString:@""]) {
        return YES;
    }
    
    if (!currentAnnotationArray) {
        return NO;
    }
    
    for (NSNumber *val in currentAnnotationArray) {
        if ([val boolValue]) {
            return YES;
        }
    }
    
    return NO;
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
        
        self.annotationView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning-small"]];
        self.annotationView.frame = CGRectMake(80,0,34,34);
        [self.contentView addSubview:self.annotationView];
        self.annotationView.hidden = ![self hasAnnotationOrNotes];
        
        self.deleteButtonIcon = [UIImage imageNamed:@"DeleteRed"];
        self.deleteButtonOffset = CGPointMake(37, 37);
        self.deleteButton.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.deleteButton.layer.shadowOpacity = 0.7;
        self.deleteButton.layer.shadowOffset = CGSizeMake(0,2);
        
        //enable logging for this object.
        //self.touchLoggingEnabled = YES;
        
        initialLayoutComplete = YES;
    }

//    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    self.layer.borderWidth = self.active ? 4.0 : 1.0;
}

-(void) setItem:(WSCDItem *)newItem
{    
    
    item = newItem;

    if (newItem.data) {
        self.imageView.image = [UIImage imageWithData:newItem.thumbnail];
    }
    else {
        self.imageView.image = nil;
    }
    
    //store the annotation array locally for performance.
    if (item.annotations) {
        currentAnnotationArray = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:item.annotations]];
    }
    else {
        //If there isn't an annotation array, create and fill one.
        int maximumAnnotations = 4;
        currentAnnotationArray = [[NSMutableArray alloc] initWithCapacity:maximumAnnotations]; //the largest (current) submodality
        for (int i = 0; i < maximumAnnotations; i++) {
            [currentAnnotationArray addObject:[NSNumber numberWithBool:NO]];
        }
    }


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
