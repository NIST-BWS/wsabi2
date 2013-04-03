// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import <UIKit/UIKit.h>

@interface BWSPickerActionSheet : NSObject <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) UIViewController *viewController;

- (BWSPickerActionSheet *)initInViewController:(UIViewController *)viewController;

// TODO: Enforce that only one picker can be on the screen at a time.
- (void)showDatePickerWithTitle:(NSString *)title forIndexPath:(NSIndexPath *)indexPath success:(void (^)(NSDate *date))success;
- (void)showDatePickerWithTitle:(NSString *)title initialDate:(NSDate *)initialDate forIndexPath:(NSIndexPath *)indexPath success:(void (^)(NSDate *date))success;

- (void)showPickerWithTitle:(NSString *)title captions:(NSArray *)captions forIndexPath:(NSIndexPath *)indexPath success:(void (^)(NSArray *indexPaths, NSArray *captions))success;
- (void)showPickerWithTitle:(NSString *)title captions:(NSArray *)captions forIndexPath:(NSIndexPath *)indexPath selectedValues:(NSArray *)indexPaths success:(void (^)(NSArray *indexPaths, NSArray *captions))success;

@end
