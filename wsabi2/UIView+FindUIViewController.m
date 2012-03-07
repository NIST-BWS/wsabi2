//
//  UIView+FindUIViewController.m
//  wsabi2
//
//  Created by Matt Aronoff on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// This is taken from http://stackoverflow.com/a/3732812

#import "UIView+FindUIViewController.h"

@implementation UIView (FindUIViewController)
- (UIViewController *) firstAvailableUIViewController {
    // convenience function for casting and to "mask" the recursive function
    return (UIViewController *)[self traverseResponderChainForUIViewController];
}

- (id) traverseResponderChainForUIViewController {
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder traverseResponderChainForUIViewController];
    } else {
        return nil;
    }
}
@end
