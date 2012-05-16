//
//  UIViewController+PopoverSizing.m
//  wsabi2
//
//  Created by Matt Aronoff on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+PopoverSizing.h"

@implementation UIViewController (PopoverSizing)

- (void) forcePopoverSize {
    [UIView animateWithDuration:0.1 animations:^{
        CGSize currentSetSizeForPopover = self.contentSizeForViewInPopover;
        CGSize fakeMomentarySize = CGSizeMake(currentSetSizeForPopover.width - 1.0f, currentSetSizeForPopover.height - 1.0f);
        self.contentSizeForViewInPopover = fakeMomentarySize;
        self.contentSizeForViewInPopover = currentSetSizeForPopover;
    }];
}

@end
