//
//  WSViewController.h
//  wsabi2
//
//  Created by Matt Aronoff on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "WSCDPerson.h"
#import "WSCDItem.h"
#import "WSCDDeviceDefinition.h"

#import "WSPersonTableViewCell.h"

@interface WSViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, WSPersonTableViewCellDelegate, NSFetchedResultsControllerDelegate>
{
    NSIndexPath *selectedIndex;
}
-(IBAction)addFirstButtonPressed:(id)sender;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *addFirstButton;

@end
