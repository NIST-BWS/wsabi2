//
//  NBCLXMLMap.m
//  wsabi2
//
//  Created by Matt Aronoff on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NBCLXMLMap.h"

@implementation NBCLXMLMap

//Based on type definitions at http://www.w3schools.com/schema/schema_dtypes_numeric.asp
+(id) objcObjectForXML:(NSString*)contentString ofType:(NSString*)typeString
{
    id result = nil;
    
    if ([typeString localizedCaseInsensitiveCompare:@"xs:int"] == NSOrderedSame || 
        [typeString localizedCaseInsensitiveCompare:@"xs:integer"] == NSOrderedSame ||
        [typeString localizedCaseInsensitiveCompare:@"xs:long"] == NSOrderedSame ||
        [typeString localizedCaseInsensitiveCompare:@"xs:negativeInteger"] == NSOrderedSame ||
        [typeString localizedCaseInsensitiveCompare:@"xs:nonNegativeInteger"] == NSOrderedSame ||
        [typeString localizedCaseInsensitiveCompare:@"xs:nonPositiveInteger"] == NSOrderedSame ||
        [typeString localizedCaseInsensitiveCompare:@"xs:positiveInteger"] == NSOrderedSame ||
        [typeString localizedCaseInsensitiveCompare:@"xs:short"] == NSOrderedSame ||            
        [typeString localizedCaseInsensitiveCompare:@"xs:unsignedLong"] == NSOrderedSame ||
        [typeString localizedCaseInsensitiveCompare:@"xs:unsignedInt"] == NSOrderedSame ||
        [typeString localizedCaseInsensitiveCompare:@"xs:unsignedShort"] == NSOrderedSame ||
        [typeString localizedCaseInsensitiveCompare:@"xs:unsignedLong"] == NSOrderedSame
        ) {
        result = [NSNumber numberWithInt:[contentString intValue]];
    }
    else if ([typeString localizedCaseInsensitiveCompare:@"xs:decimal"] == NSOrderedSame ||
             [typeString localizedCaseInsensitiveCompare:@"xs:float"] == NSOrderedSame ||
             [typeString localizedCaseInsensitiveCompare:@"xs:double"] == NSOrderedSame)
    {
        result = [NSNumber numberWithInt:[contentString doubleValue]];
    }
    
    else if ([typeString localizedCaseInsensitiveCompare:@"xs:boolean"] == NSOrderedSame)
    {
        result = [NSNumber numberWithBool:
                  ([contentString localizedCaseInsensitiveCompare:@"true"] == NSOrderedSame)
                 ];
    }
    else {
        //fall back to storing this as a string
        result = contentString;
    }
   
    return result;
}

@end
