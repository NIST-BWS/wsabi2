//
//  WSItemGridCell.h
//  wsabi2
//
//  Created by Matt Aronoff on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSItemGridCell : KKGridViewCell
{
    BOOL initialLayoutComplete;
}

@property (nonatomic, strong) IBOutlet UIButton *deleteButton;

@end
