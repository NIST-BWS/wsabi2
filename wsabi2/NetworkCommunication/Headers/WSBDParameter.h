// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import <Foundation/Foundation.h>

@interface WSBDParameter : NSObject <NSCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) id defaultValue; //either an NSNumber or a string
@property (nonatomic) BOOL readOnly;
@property (nonatomic) BOOL supportsMultiple;
@property (nonatomic, strong) NSMutableArray *allowedValues;

- (id)initWithParameter:(WSBDParameter *)parameter;

@end
