//
//  WSItemGridCell.m
//  wsabi2
//
//  Created by Matt Aronoff on 1/18/12.
 
//

#import "WSItemGridCell.h"

@implementation WSItemGridCell

@synthesize item;
@synthesize imageView;
@synthesize placeholderView;
@synthesize placeholderLabel;
@synthesize shadowView;
@synthesize badge;
@synthesize active;
@synthesize selected;

- (id) init
{
    self = [super init];
    if (self) {
        // Initialization code
        self.imageView = [[UIImageView alloc] init];
        [self startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
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

-(void) configureView
{
    //NSLog(@"Configuring a cell with modality %@ and submodality %@",self.item.modality,self.item.submodality);
    //this may be called from inside the setItem method, so use the ivar, not the property.
    if (self.item.data) {
        self.imageView.image = [UIImage imageWithData:self.item.thumbnail];
        self.placeholderView.image = nil;
        self.placeholderView.hidden = YES;
    }
    else {
        self.imageView.image = nil;
        
        NSString *imageName = nil;
        switch ([WSModalityMap modalityForString:self.item.modality]) {
            case kModalityEar:
                imageName = @"modality-ear";
                break;
            case kModalityFace:
                imageName = @"modality-face";
                break;
            case kModalityFinger:
                imageName = @"modality-finger-rotated";
                break;
            case kModalityFoot:
                imageName = @"modality-foot";
                break;
            case kModalityIris:
                imageName = @"modality-iris";
                break;
            case kModalityRetina:
                imageName = @"modality-iris";
                break;
            case kModalityVein:
                imageName = @"modality-vein";
                break;
            case kModalityOther:
                /* FALLTHROUGH */
            default:
                break;
        }
                
        if (imageName) {
            self.placeholderView.image = [UIImage imageNamed:imageName];
            self.placeholderView.hidden = NO;
        }
        else {
            //hide the placeholder for now
            self.placeholderView.image = nil;
            self.placeholderView.hidden = YES;
        }
        
        //if (self.placeholderLabel.text.length 
    }
    
    //configure the submodality label
    self.placeholderLabel.text = self.item.submodality ? self.item.submodality : @"";
    self.accessibilityLabel = self.placeholderLabel.text;
    
    //store the annotation array locally for performance.
    if (self.item.annotations) {
        currentAnnotationArray = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:self.item.annotations]];
    }
    else {
        //If there isn't an annotation array, create and fill one.
        int maximumAnnotations = 4;
        currentAnnotationArray = [[NSMutableArray alloc] initWithCapacity:maximumAnnotations]; //the largest (current) submodality
        for (int i = 0; i < maximumAnnotations; i++) {
            [currentAnnotationArray addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    if (self.placeholderLabel.text.length > 11){
        NSLog(@"%@", self.placeholderLabel.text);
        self.placeholderLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.placeholderLabel.numberOfLines = 2;    }
    else {
        self.placeholderLabel.numberOfLines = 1;
    }
    
    //
    // Configure the badge
    //
    NSUInteger badgeNumber = 0;
    for (NSNumber *num in currentAnnotationArray)
        if ([num boolValue] == YES)
            badgeNumber++;
    // Note counts as an annotation
    if (self.item.notes && ![self.item.notes isEqualToString:@""])
        badgeNumber++;
    [[self badge] setHidden:(badgeNumber == 0)];

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
        self.shadowView.frame = CGRectInset(view.bounds, -12, (kItemCellSizeVerticalAddition/2.0) -12); //make this bigger than the cell.
        self.shadowView.center = CGPointMake(self.contentView.center.x, self.contentView.center.y - kItemCellSizeVerticalAddition);
        [self.contentView addSubview:self.shadowView];
        
        self.imageView.frame = CGRectMake(0,0,self.contentView.bounds.size.width, self.contentView.bounds.size.height - kItemCellSizeVerticalAddition);
        self.imageView.center = self.shadowView.center;
        [self.contentView addSubview:self.imageView];
        
        self.placeholderView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        self.placeholderView.contentMode = UIViewContentModeCenter;
        self.placeholderView.center = self.shadowView.center;
        [self.contentView addSubview:self.placeholderView];
        
        self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.contentView.bounds, 12, 47)];
        self.placeholderLabel.backgroundColor = [UIColor clearColor];
        self.placeholderLabel.textAlignment = UITextAlignmentCenter;
        self.placeholderLabel.textColor = [UIColor whiteColor];
        self.placeholderLabel.font = [UIFont systemFontOfSize:15];
        //position this below the placeholder view.
        self.placeholderLabel.center = CGPointMake(self.shadowView.center.x, 
                                                   self.contentView.bounds.size.height - self.placeholderLabel.bounds.size.height/2.0);
        
        [self.contentView addSubview:self.placeholderLabel];
        
        // Badge containing number of annotations + notes
	[self setBadge:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blue_info_badge"]]];
        [[self badge] setFrame:CGRectMake(self.contentView.bounds.size.width - 20, -20, 29, 31)];
        
        // XXX: Perhaps the badge should pass the touch event through
        [[self badge] setUserInteractionEnabled:NO];
        
        [[self badge] setHidden:![self hasAnnotationOrNotes]];
        [[self contentView] addSubview:self.badge];
        
        self.deleteButtonIcon = [UIImage imageNamed:@"DeleteRed"];
        self.deleteButtonOffset = CGPointMake(37, 28);
        self.deleteButton.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.deleteButton.layer.shadowOpacity = 0.7;
        self.deleteButton.layer.shadowOffset = CGSizeMake(0,2);
        
        //enable logging for this object.
        //self.touchLoggingEnabled = YES;
        
        [self configureView];
        
        initialLayoutComplete = YES;
    }

//    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    self.layer.borderWidth = self.active ? 4.0 : 1.0;
    [self configureView];
}

-(void) setItem:(WSCDItem *)newItem
{    
    
    item = newItem;

    [self setNeedsDisplay];
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

- (void)dealloc
{
    [self stopLoggingBWSInterfaceEvents];
}

@end
