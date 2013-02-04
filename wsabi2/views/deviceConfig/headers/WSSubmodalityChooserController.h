//
//  WSSubmodalityChooser.h
//  wsabi2
//
//  Created by Matt Aronoff on 2/3/12.
 
//

#import <UIKit/UIKit.h>
#import "WSCDItem.h"
#import "WSCDDeviceDefinition.h"
#import "BWSModalityMap.h"
#import "WSDeviceChooserController.h"

@interface WSSubmodalityChooserController : UITableViewController
{
    NSArray *submodalities;
}

-(IBAction) currentButtonPressed:(id)sender;

@property (nonatomic) WSSensorModalityType modality;
@property (nonatomic, strong) WSCDItem *item;
@property (nonatomic, strong) UIBarButtonItem *currentButton;
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer *tapBehindViewRecognizer;

- (IBAction)tappedBehindView:(id)sender;

@end
