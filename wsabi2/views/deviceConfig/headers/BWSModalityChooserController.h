//
//  WSModalityChooserController.h
//  wsabi2
//
//  Created by Matt Aronoff on 2/3/12.
 
//

#import <UIKit/UIKit.h>
#import "BWSCDItem.h"
#import "BWSCDDeviceDefinition.h"
#import "BWSModalityMap.h"
#import "BWSSubmodalityChooserController.h"

@interface BWSModalityChooserController : UITableViewController

-(IBAction) tappedBehindView:(id)sender;
-(IBAction) currentButtonPressed:(id)sender;

@property (nonatomic, strong) BWSCDItem *item;

@property (nonatomic, strong) UIBarButtonItem *currentButton;
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer *tapBehindViewRecognizer;

@end
