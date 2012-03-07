//
//  UIView+FindUIViewController.h
//  wsabi2
//
//  Created by Matt Aronoff on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// This is taken from http://stackoverflow.com/a/3732812

#import <UIKit/UIKit.h>

@interface UIView (FindUIViewController)
- (UIViewController *) firstAvailableUIViewController;
- (id) traverseResponderChainForUIViewController;
@end
