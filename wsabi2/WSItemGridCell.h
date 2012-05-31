//
//  WSItemGridCell.h
//  wsabi2
//
//  Created by Matt Aronoff on 1/18/12.
 
//

#import <UIKit/UIKit.h>
#import "GMGridViewCell.h"
#import "GMGridViewCell+Extended.h"
#import "WSModalityMap.h"
#import "UIView+GMGridViewAdditions.h"
#import "WSCDItem.h"
#import "constants.h"

//@protocol WSItemGridCellDelegate <NSObject>
//
//-(void) didRequestItemDeletion:(WSCDItem*)item;
//
//@end

@interface WSItemGridCell : GMGridViewCell <UIActionSheetDelegate>
{
    BOOL initialLayoutComplete;
    NSMutableArray *currentAnnotationArray;
}

//-(void) deleteButtonPressed:(id)sender;

//@property (nonatomic, unsafe_unretained) id<WSItemGridCellDelegate> delegate;

-(void) configureView;

@property (nonatomic, strong) WSCDItem *item;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *placeholderView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UIImageView *shadowView;
@property (nonatomic, strong) UIImageView *annotationView;

@property (nonatomic) BOOL active;
@property (nonatomic) BOOL selected;

@end
