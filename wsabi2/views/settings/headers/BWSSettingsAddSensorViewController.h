// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import <UIKit/UIKit.h>

/// Navigation item title for this view
static NSString * const kWSSettingsAddSensorVCTitle = @"Add Sensor";
/// Number of components in modality PickerView
static const NSInteger kWSSettingsAddSensorVCNumberOfComponents = 2;
/// Component number for the modality component of the PickerView
static const NSInteger kWSSettingsAddSensorVCModalityComponent = 0;
/// Component number for the submodality component of the PickerView
static const NSInteger kWSSettingsAddSensorVCSubmodalityComponent = 1;

@interface BWSSettingsAddSensorViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@end
