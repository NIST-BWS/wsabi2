// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import "WSBDResource.h"

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

- (id)initWithParameter:(WSBDParameter *)parameter
{
    self.name = [NSString stringWithString:parameter.name];
    self.type = [NSString stringWithString:parameter.type];
    // TODO: Must be a better way
    if ([parameter.defaultValue isKindOfClass:[NSNumber class]])
        self.defaultValue = [NSNumber numberWithDouble:[parameter.defaultValue doubleValue]];
    if ([parameter.defaultValue isKindOfClass:[NSString class]])
        self.defaultValue = [NSString stringWithString:parameter.defaultValue];
    else if ([parameter.defaultValue isKindOfClass:[WSBDResource class]]) {
        self.defaultValue = [[WSBDResource alloc] init];
        ((WSBDResource *)self.defaultValue).uri = ((WSBDResource *)parameter.defaultValue).uri;
        //((WSBDResource *)self.defaultValue).uri = [NSURL URLWithString:@"http://10.0.0.69/verifier/Stream"];
        //((WSBDResource *)self.defaultValue).uri = [NSURL URLWithString:@"http://10.0.0.69/supremaservice/Stream"];
        //((WSBDResource *)self.defaultValue).uri = [NSURL URLWithString:@"http://10.0.0.69:8000/Service/Stream"];
	    
	    ((WSBDResource *)self.defaultValue).contentType = ((WSBDResource *)parameter.defaultValue).contentType;
        ((WSBDResource *)self.defaultValue).relationship = ((WSBDResource *)parameter.defaultValue).relationship;
    }
    self.readOnly = parameter.readOnly;
    self.supportsMultiple = parameter.supportsMultiple;
    self.allowedValues = [[NSMutableArray alloc] initWithArray:parameter.allowedValues copyItems:YES];

    return (self);
}

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
