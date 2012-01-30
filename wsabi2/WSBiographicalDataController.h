//
//  WSBiographicalDataController.h
//  wsabi2
//
//  Created by Matt Aronoff on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSCDPerson.h"

#define kSectionBasic 0
#define kSectionGender 1
#define kSectionDescriptive 2

@interface WSBiographicalDataController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) WSCDPerson *person;
@property (nonatomic, strong) IBOutlet UITableView *bioDataTable;

@end
