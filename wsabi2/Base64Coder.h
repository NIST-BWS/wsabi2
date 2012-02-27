//
//  Base64Coder.h
//  SensorInterfaceTest
//
//  Created by Matt Aronoff on 10/20/09.
//

// Updated Feb 2012 for ARC support

/*
 This software was developed at the National Institute of Standards and Technology by employees of the Federal Government
 in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not 
 subject to copyright protection and is in the public domain. Wsabi is an experimental system. NIST assumes no responsibility 
 whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or 
 any other characteristic. We would appreciate acknowledgement if the software is used.
 */


#import <Foundation/Foundation.h>


@interface Base64Coder : NSObject {

}

+ (void) initialize;
+ (NSString*) encode:(const uint8_t*) input length:(NSInteger) length;

+ (NSString*) encode:(NSData*) rawBytes;

+ (NSData*) decode:(const char*) string length:(NSInteger) inputLength;

+ (NSData*) decode:(NSString*) string;

@end
