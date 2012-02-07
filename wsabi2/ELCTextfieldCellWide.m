//
//  ELCTextfieldCellWide.m
//  wsabi2
//
//  Created by Matt Aronoff on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ELCTextfieldCellWide.h"

@implementation ELCTextfieldCellWide

//Perform a different layout here than in the standard cell, to take
//advantage of extra width.
- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect origFrame = self.contentView.frame;
	if (leftLabel.text != nil) {
		leftLabel.frame = CGRectMake(origFrame.origin.x, origFrame.origin.y, 150, origFrame.size.height-1);
		rightTextField.frame = CGRectMake(origFrame.origin.x+165, origFrame.origin.y, origFrame.size.width-180, origFrame.size.height-1);
	} else {
		leftLabel.hidden = YES;
		NSInteger imageWidth = 0;
		if (self.imageView.image != nil) {
			imageWidth = self.imageView.image.size.width + 5;
		}
		rightTextField.frame = CGRectMake(origFrame.origin.x+imageWidth+10, origFrame.origin.y, origFrame.size.width-imageWidth-20, origFrame.size.height-1);
	}
}

@end
