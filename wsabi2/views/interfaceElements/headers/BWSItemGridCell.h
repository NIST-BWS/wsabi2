// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import <UIKit/UIKit.h>
#import "GMGridViewCell.h"
#import "GMGridViewCell+Extended.h"
#import "BWSModalityMap.h"
#import "UIView+GMGridViewAdditions.h"
#import "BWSCDItem.h"
#import "BWSConstants.h"

//@protocol WSItemGridCellDelegate <NSObject>
//
//-(void) didRequestItemDeletion:(WSCDItem*)item;
//
//@end

@interface BWSItemGridCell : GMGridViewCell <UIActionSheetDelegate>
{
    BOOL initialLayoutComplete;
    NSMutableArray *currentAnnotationArray;
}

//-(void) deleteButtonPressed:(id)sender;

//@property (nonatomic, unsafe_unretained) id<WSItemGridCellDelegate> delegate;

-(void) configureView;

@property (nonatomic, strong) BWSCDItem *item;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *placeholderView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UIImageView *shadowView;
@property (nonatomic, strong) UIImageView *badge;

@property (nonatomic) BOOL active;
@property (nonatomic) BOOL selected;

@end
