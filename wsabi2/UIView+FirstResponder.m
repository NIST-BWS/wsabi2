//
//  UIView+FirstResponder.m
//  wsabi2
//
//  Created by Matt Aronoff on 2/3/12.
 
//

// Based on code from http://www.floydprice.com/2011/12/ios-find-the-current-responder/

#import "UIView+FirstResponder.h"

@implementation UIView (FirstResponder)

- (UIView *)findFirstResponder
{
    if (self.isFirstResponder) {
        return self;
    }
    for (UIView *subView in self.subviews) {
        if ([subView isFirstResponder]){
            return subView;
        }
        if ([subView findFirstResponder]){
            return [subView findFirstResponder];
        }
    }
    return nil;
}

@end
