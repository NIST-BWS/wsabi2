//
//  WsabiExtras.h
//  Wsabi
//
//  Created by Matt Aronoff on 3/7/11.
//

/*
 This software was developed at the National Institute of Standards and Technology by employees of the Federal Government
 in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not 
 subject to copyright protection and is in the public domain. Wsabi is an experimental system. NIST assumes no responsibility 
 whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or 
 any other characteristic. We would appreciate acknowledgement if the software is used.
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (NBCLExtras)

+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)targetSize;

@end
