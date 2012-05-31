//
//  WSModalityChooserController.h
//  wsabi2
//
//  Created by Matt Aronoff on 2/3/12.
 
//

#import <UIKit/UIKit.h>
#import "WSCDItem.h"
#import "WSCDDeviceDefinition.h"
#import "WSModalityMap.h"
#import "WSSubmodalityChooserController.h"

@interface WSModalityChooserController : UITableViewController

-(IBAction) cancelButtonPressed:(id)sender;
-(IBAction) currentButtonPressed:(id)sender;

@property (nonatomic, strong) WSCDItem *item;

@property (nonatomic, strong) UIBarButtonItem *currentButton;

@end
