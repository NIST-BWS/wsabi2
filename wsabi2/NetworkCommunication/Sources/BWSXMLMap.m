//
//  NBCLXMLMap.m
//  wsabi2
//
//  Created by Matt Aronoff on 3/14/12.
 
//

#import "BWSXMLMap.h"

@implementation BWSXMLMap

//NOTE: In the long term, this should almost certainly be replaced by an implementation that's
//more closely tied to a smart XML implementation.

//Based on type definitions at http://www.w3schools.com/schema/schema_dtypes_numeric.asp
+(id) objcObjectForXML:(NSString*)contentString ofType:(NSString*)typeString
{
    id result = nil;
    
    if ([typeString localizedCaseInsensitiveCompare:@"xs:int"] == NSOrderedSame || 
        [typeString localizedCaseInsensitiveCompare:@"xs:integer"] == NSOrderedSame ||
        [typeString localizedCaseInsensitiveCompare:@"xs:negativeInteger"] == NSOrderedSame ||
        [typeString localizedCaseInsensitiveCompare:@"xs:nonNegativeInteger"] == NSOrderedSame ||
        [typeString localizedCaseInsensitiveCompare:@"xs:nonPositiveInteger"] == NSOrderedSame
        ) {
        result = [NSNumber numberWithInt:[contentString intValue]];
    }
    else if ([typeString localizedCaseInsensitiveCompare:@"xs:float"] == NSOrderedSame)
    {
        result = [NSNumber numberWithFloat:[contentString floatValue]];
    }
    else if ([typeString localizedCaseInsensitiveCompare:@"xs:short"] == NSOrderedSame)
    {
        result = [NSNumber numberWithShort:[contentString intValue]];
    }

    else if ([typeString localizedCaseInsensitiveCompare:@"xs:long"] == NSOrderedSame)
    {
        //Apparently longValue doesn't exist.
        result = [NSNumber numberWithLong:[contentString doubleValue]];
    }
    
    else if ([typeString localizedCaseInsensitiveCompare:@"xs:positiveInteger"] == NSOrderedSame)
    {
        result = [NSNumber numberWithInt:abs([contentString intValue])];
    }

    else if ([typeString localizedCaseInsensitiveCompare:@"xs:unsignedLong"] == NSOrderedSame)
    {
        //Apparently longValue doesn't exist.
        result = [NSNumber numberWithUnsignedLong:labs([contentString doubleValue])];
    }

    else if ([typeString localizedCaseInsensitiveCompare:@"xs:unsignedInt"] == NSOrderedSame)
    {
        result = [NSNumber numberWithUnsignedInt:abs([contentString intValue])];
    }

    else if ([typeString localizedCaseInsensitiveCompare:@"xs:unsignedShort"] == NSOrderedSame)
    {
        result = [NSNumber numberWithUnsignedShort:abs([contentString intValue])];
    }
    

    else if ([typeString localizedCaseInsensitiveCompare:@"xs:decimal"] == NSOrderedSame ||
             [typeString localizedCaseInsensitiveCompare:@"xs:double"] == NSOrderedSame)
    {
        result = [NSNumber numberWithDouble:[contentString doubleValue]];
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

//NOTE: This is definitely going to lose some information (negativeInteger, for example, will come out as an int)
+(NSString*) xmlElementForObject:(id)sourceObject withElementName:(NSString*)elementName
{
    NSString *typeName = @"xs:string"; //default type
    
    NSString *objectValue = @"";
    
    if (!sourceObject) {
        //nothing to do. Leave it blank.
    }
    else if ([sourceObject isKindOfClass:[NSNumber class]])
    {
        //figure out what sort of number we should create.
        if (strcmp([sourceObject objCType], @encode(int)) == 0) {
            //e.g., this is an int.
            typeName = @"xs:int";
            objectValue = [NSString stringWithFormat:@"%d", [sourceObject intValue]];
        }
        else if (strcmp([sourceObject objCType], @encode(float)) == 0) {
            typeName = @"xs:float";
            objectValue = [NSString stringWithFormat:@"%1.2f", [sourceObject floatValue]];

        }
        else if (strcmp([sourceObject objCType], @encode(double)) == 0) {
            typeName = @"xs:double";
            objectValue = [NSString stringWithFormat:@"%1.2f", [sourceObject doubleValue]];
            
        }

        else if (strcmp([sourceObject objCType], @encode(short)) == 0) {
            //This is an int.
            typeName = @"xs:short";
            objectValue = [NSString stringWithFormat:@"%d", [sourceObject shortValue]];
        }

        else if (strcmp([sourceObject objCType], @encode(unsigned int)) == 0) {
            typeName = @"xs:unsignedInt";
            objectValue = [NSString stringWithFormat:@"%x", [sourceObject unsignedIntValue]];
            
        }
        else if (strcmp([sourceObject objCType], @encode(unsigned short)) == 0) {
            typeName = @"xs:unsignedShort";
            objectValue = [NSString stringWithFormat:@"%x", [sourceObject unsignedShortValue]];
            
        }
        else if (strcmp([sourceObject objCType], @encode(unsigned long)) == 0) {
            typeName = @"xs:unsignedLong";
            objectValue = [NSString stringWithFormat:@"%1.2lu", [sourceObject unsignedLongValue]];
            
        }
        else if (strcmp([sourceObject objCType], @encode(BOOL)) == 0) {
            typeName = @"xs:boolean";
            objectValue = ([sourceObject boolValue] ? @"true" : @"false");
            
        }
        else {
            //default to a string type for numbers we don't recognize
            typeName = @"xs:string";
            objectValue = [sourceObject stringValue];
        }

    }
    else if ([sourceObject isKindOfClass:[NSString class]])
    {
        objectValue = sourceObject;
    }
    else {
        //default to trying to get a string representation.
        if ([sourceObject respondsToSelector:@selector(stringValue)]) {
            objectValue = [sourceObject stringValue];
        }
    }
    
    
    NSString *result = [NSString stringWithFormat:@"<%@ i:type=\"%@\">%@</%@>",elementName, typeName, objectValue, elementName];
    
    return result;
}

@end
