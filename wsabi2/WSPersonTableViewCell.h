//
//  WSItemGridCell.h
//  wsabi2
//
//  Created by Matt Aronoff on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSCDPerson.h"
#import "WSCDItem.h"
#import "WSItemGridCell.h"
#import "constants.h"

@protocol WSPersonTableViewCellDelegate <NSObject>

-(void) didRequestDuplicatePerson:(WSCDPerson*)person;
-(void) didRequestDeletePerson:(WSCDPerson*)person;

@end

@interface WSPersonTableViewCell : UITableViewCell <KKGridViewDataSource, KKGridViewDelegate, WSItemGridCellDelegate, UIActionSheetDelegate>
{
    BOOL initialLayoutComplete;
    NSArray *orderedItems;
    
    UIActionSheet *deletePersonSheet;
}

-(void) updateData;

-(IBAction)addItemButtonPressed:(id)sender;
-(IBAction)duplicateRowButtonPressed:(id)sender;
-(IBAction)editButtonPressed:(id)sender;
-(IBAction)deleteButtonPressed:(id)sender;

@property (nonatomic, strong) WSCDPerson *person;
@property (nonatomic, strong) IBOutlet KKGridView *cellGridView;
@property (nonatomic, strong) IBOutlet UIButton *editButton;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) IBOutlet UIButton *addButton;
@property (nonatomic, strong) IBOutlet UIButton *duplicateRowButton;

@property (nonatomic, strong) IBOutlet UIImageView *customSelectedBackgroundView;

@property (nonatomic, unsafe_unretained) id<WSPersonTableViewCellDelegate> delegate;

@end
