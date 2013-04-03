// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import "BWSPickerActionSheet.h"

static const CGFloat kBWSPickerActionSheetDefaultToolbarHeight = 44.0;
static const CGFloat kBWSPickerActionSheetDefaultPickerHeight = 216.0;
static const CGFloat kBWSPickerActionSheetDefaultToolbarTitleSize = 17.0;
static const CGFloat kBWSPickerACtionSheetDefaultAnimationTime = 0.3;

@interface BWSPickerActionSheet ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *fadeView;

@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, copy) void (^dateSucess)(NSDate *date);

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *captions;
@property (nonatomic, strong) void (^pickerSuccess)(NSArray *indexPaths, NSArray *captions);

@end

@implementation BWSPickerActionSheet

#pragma mark - Initialization

- (BWSPickerActionSheet *)initInViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self == nil)
        return (nil);

    [self setViewController:viewController];
    
    return (self);
}

#pragma mark - Date Pickers

- (void)showDatePickerWithTitle:(NSString *)title forIndexPath:(NSIndexPath *)indexPath success:(void (^)(NSDate *date))success;
{
	[self showDatePickerWithTitle:title initialDate:[NSDate date] forIndexPath:indexPath success:success];
}

- (void)showDatePickerWithTitle:(NSString *)title initialDate:(NSDate *)initialDate forIndexPath:(NSIndexPath *)indexPath success:(void (^)(NSDate *date))success
{
    self.dateSucess = success;
	[self boilerPlateWithTitle:title indexPath:indexPath successSelector:@selector(BWSActionSheetDatePickerViewDoneButtonPressed:)];
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, kBWSPickerActionSheetDefaultToolbarHeight, self.containerView.frame.size.width, kBWSPickerActionSheetDefaultPickerHeight)];
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    if (initialDate != nil)
	    [self.datePicker setDate:initialDate];
    [self.containerView addSubview:self.datePicker];
    
    [self addAndDisplayView];
}

- (void)showPickerWithTitle:(NSString *)title captions:(NSArray *)captions forIndexPath:(NSIndexPath *)indexPath success:(void (^)(NSArray *indexPaths, NSArray *captions))success
{
    [self showPickerWithTitle:title captions:captions forIndexPath:indexPath selectedValues:nil success:success];
}

- (void)showPickerWithTitle:(NSString *)title captions:(NSArray *)captions forIndexPath:(NSIndexPath *)indexPath selectedValues:(NSArray *)indexPaths success:(void (^)(NSArray *indexPaths, NSArray *captions))success
{
    self.pickerSuccess = success;
	[self boilerPlateWithTitle:title indexPath:indexPath successSelector:@selector(BWSActionSheetPickerViewDoneButtonPressed:)];

    [self setCaptions:captions];
	self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, kBWSPickerActionSheetDefaultToolbarHeight, self.containerView.frame.size.width, kBWSPickerActionSheetDefaultPickerHeight)];
    [self.pickerView setDataSource:self];
    [self.pickerView setDelegate:self];
    [self.pickerView setShowsSelectionIndicator:YES];
    
    if (indexPaths != nil)
	    for (NSIndexPath *indexPath in indexPaths)
    		[self.pickerView selectRow:indexPath.row inComponent:indexPath.section animated:NO];
    
    [self.containerView addSubview:self.pickerView];

    [self addAndDisplayView];
}

#pragma mark - Both Pickers

- (void)boilerPlateWithTitle:(NSString *)title indexPath:(NSIndexPath *)indexPath successSelector:(SEL)successSelector
{
    NSAssert(self.viewController != nil, @"View property not set");
    [self.viewController.view endEditing:YES];

    self.indexPath = indexPath;

	self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.viewController.view.frame), self.viewController.view.frame.size.width, kBWSPickerActionSheetDefaultPickerHeight + kBWSPickerActionSheetDefaultToolbarHeight)];

    [self allocateFadeView];
    [self.viewController.view addSubview:self.fadeView];

    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.containerView.frame.size.width, kBWSPickerActionSheetDefaultToolbarHeight)];
    [toolbar setBarStyle:UIBarStyleBlackOpaque];
	UIBarButtonItem *toolbarCancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(BWSActionSheetPickerViewCancelButtonPressed:)];
    UIBarButtonItem *toolbarDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:successSelector];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    UILabel *toolbarTitle = [[UILabel alloc] init];
    toolbarTitle.text = title;
    toolbarTitle.textColor = [UIColor whiteColor];
    toolbarTitle.font = [UIFont boldSystemFontOfSize:kBWSPickerActionSheetDefaultToolbarTitleSize];
    [toolbarTitle sizeToFit];
    toolbarTitle.center = CGPointMake(CGRectGetMidX(toolbar.frame), CGRectGetMidY(toolbar.frame));
    toolbarTitle.backgroundColor = [UIColor clearColor];
    UIBarButtonItem *toolbarCaptionButton = [[UIBarButtonItem alloc] initWithCustomView:toolbarTitle];

    [toolbar setItems:@[toolbarCancelButton, flexibleSpace, toolbarCaptionButton, flexibleSpace, toolbarDoneButton]];
    [self.containerView addSubview:toolbar];
}

- (void)addAndDisplayView
{
    [self.viewController.view addSubview:self.containerView];
    [UIView animateWithDuration:kBWSPickerACtionSheetDefaultAnimationTime animations:^() {
        [self.fadeView setAlpha:0.7];
        [self.containerView setFrame:CGRectOffset(self.containerView.frame, 0, -(kBWSPickerActionSheetDefaultPickerHeight + kBWSPickerActionSheetDefaultToolbarHeight))];
    }];
}

#pragma mark - Button Events

- (IBAction)BWSActionSheetPickerViewCancelButtonPressed:(id)cancelButton
{
    [self removeBWSViews];
}

- (void)BWSActionSheetDatePickerViewDoneButtonPressed:(id)doneButton
{
	if (self.dateSucess != nil)
        self.dateSucess(self.datePicker.date);

    [self removeBWSViews];
}

- (void)BWSActionSheetPickerViewDoneButtonPressed:(id)doneButton
{
    if (self.pickerSuccess != nil) {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:self.pickerView.numberOfComponents];
        NSMutableArray *captions = [[NSMutableArray alloc] initWithCapacity:self.pickerView.numberOfComponents];
        for (NSUInteger component = 0; component < [self.pickerView numberOfComponents]; component++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:[self.pickerView selectedRowInComponent:component] inSection:component]];
            [captions addObject:[self.pickerView.delegate pickerView:self.pickerView titleForRow:[self.pickerView selectedRowInComponent:component] forComponent:component]];
        }
        
		self.pickerSuccess(indexPaths, captions);
    }

    [self removeBWSViews];
}

#pragma mark - View Helpers

- (void)removeBWSViews
{
    [UIView animateWithDuration:kBWSPickerACtionSheetDefaultAnimationTime
                     animations:^() {
                         [self.fadeView setAlpha:0];
                         [self.containerView setFrame:CGRectOffset(self.containerView.frame, 0, (kBWSPickerActionSheetDefaultPickerHeight + kBWSPickerActionSheetDefaultToolbarHeight))];
                     } completion:^(BOOL finished) {                         
                         [self.fadeView removeFromSuperview];
                         [self.containerView removeFromSuperview];
                     }
     ];
}

- (void)allocateFadeView
{
    if (self.fadeView == nil) {
	    self.fadeView = [[UIView alloc] init];
	    [self.fadeView setBackgroundColor:[UIColor blackColor]];
	    [self.fadeView setAlpha:0.0];
    }
    
    [self.fadeView setFrame:self.viewController.view.frame];
}

#pragma mark - PickerView Delegate/DataSource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	// TODO: Support more than one component
    if (row < [self.captions count])
	    return (self.captions[row]);
    
    return (@"");
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    // TODO: Support more than one component
	return (1);
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    // TODO: Support more than one component
    return ([self.captions count]);
}

@end

