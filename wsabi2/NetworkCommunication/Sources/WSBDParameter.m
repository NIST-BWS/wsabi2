// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import "WSBDParameter.h"


static NSString * const kWSBDParamaterAttributeName = @"name";
static NSString * const kWSBDParamaterAttributeType = @"type";
static NSString * const kWSBDParamaterAttributeDefaultValue = @"defaultValue";
static NSString * const kWSBDParamaterAttributeReadOnly = @"readOnly";
static NSString * const kWSBDParamaterAttributesupportsMultiple = @"supportsMultiple";
static NSString * const kWSBDParamaterAttributeAllowedValues = @"allowedValues";

@implementation WSBDParameter

@synthesize name;
@synthesize type;
@synthesize defaultValue;
@synthesize allowedValues;
@synthesize readOnly;
@synthesize supportsMultiple;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self == nil)
        return (nil);

	self.name = [aDecoder decodeObjectForKey:kWSBDParamaterAttributeName];
    self.type = [aDecoder decodeObjectForKey:kWSBDParamaterAttributeType];
    self.defaultValue = [aDecoder decodeObjectForKey:kWSBDParamaterAttributeDefaultValue];
    self.readOnly = [aDecoder decodeBoolForKey:kWSBDParamaterAttributeReadOnly];
    self.supportsMultiple = [aDecoder decodeBoolForKey:kWSBDParamaterAttributesupportsMultiple];
    self.allowedValues = [aDecoder decodeObjectForKey:kWSBDParamaterAttributeAllowedValues];

    return (self);
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:kWSBDParamaterAttributeName];
    [aCoder encodeObject:self.type forKey:kWSBDParamaterAttributeType];
    [aCoder encodeObject:self.defaultValue forKey:kWSBDParamaterAttributeDefaultValue];
    [aCoder encodeBool:self.readOnly forKey:kWSBDParamaterAttributeReadOnly];
    [aCoder encodeBool:self.supportsMultiple forKey:kWSBDParamaterAttributesupportsMultiple];
    [aCoder encodeObject:allowedValues forKey:kWSBDParamaterAttributeAllowedValues];
}


@end
