// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

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
