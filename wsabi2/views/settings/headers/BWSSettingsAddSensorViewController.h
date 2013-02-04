//
//  WSSettingsAddSensorViewController.h
//  wsabi2
//
//  Created by Greg Fiumara on 10/17/12.
//
//

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
