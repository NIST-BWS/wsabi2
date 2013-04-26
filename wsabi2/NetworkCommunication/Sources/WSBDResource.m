// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import "WSBDResource.h"

static NSString * const kWSBDResourceAttributeURI = @"uri";
static NSString * const kWSBDResourceAttributeContentType = @"contentType";
static NSString * const kWSBDResourceAttributeRelationship = @"relationship";

@implementation WSBDResource

- (NSString *)description
{
    return ([NSString stringWithFormat:@"URI: %@, Content-Type: %@, Relationship: %@", self.uri, self.contentType, self.relationship]);
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self == nil)
        return (nil);

	self.uri = [aDecoder decodeObjectForKey:kWSBDResourceAttributeURI];
    self.contentType = [aDecoder decodeObjectForKey:kWSBDResourceAttributeContentType];
    self.relationship = [aDecoder decodeObjectForKey:kWSBDResourceAttributeRelationship];

    return (self);
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.uri forKey:kWSBDResourceAttributeURI];
    [aCoder encodeObject:self.contentType forKey:kWSBDResourceAttributeContentType];
    [aCoder encodeObject:self.relationship forKey:kWSBDResourceAttributeRelationship];
}

@end
