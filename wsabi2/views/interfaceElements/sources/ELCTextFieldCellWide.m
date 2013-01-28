//
//  ELCTextfieldCellWide.m
//  wsabi2
//
//  Created by Matt Aronoff on 2/3/12.
 
//

#import "ELCTextFieldCellWide.h"

@implementation ELCTextFieldCellWide

//Perform a different layout here than in the standard cell, to take
//advantage of extra width.
- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect origFrame = self.contentView.frame;
	if (self.leftLabel.text != nil) {
		self.leftLabel.frame = CGRectMake(origFrame.origin.x+12, origFrame.origin.y, 150, origFrame.size.height-1);
		self.rightTextField.frame = CGRectMake(origFrame.origin.x+165, origFrame.origin.y, origFrame.size.width-180, origFrame.size.height-1);
	} else {
		self.leftLabel.hidden = YES;
		NSInteger imageWidth = 0;
		if (self.imageView.image != nil) {
			imageWidth = self.imageView.image.size.width + 5;
		}
		self.rightTextField.frame = CGRectMake(origFrame.origin.x+imageWidth+10, origFrame.origin.y, origFrame.size.width-imageWidth-20, origFrame.size.height-1);
	}
}

@end
