//
//  WSItemGridCell.h
//  wsabi2
//
//  Created by Matt Aronoff on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQGridView.h"
#import "WSCDPerson.h"

@interface WSPersonTableViewCell : UITableViewCell <AQGridViewDataSource, AQGridViewDelegate>

@property (nonatomic, strong) WSCDPerson *person;
@property (nonatomic, strong) IBOutlet AQGridView *gridView;

@end
