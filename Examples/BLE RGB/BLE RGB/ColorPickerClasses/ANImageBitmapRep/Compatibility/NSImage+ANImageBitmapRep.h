//
//  NSImage+ANImageBitmapRep.h
//  ImageBitmapRep
//
//  Created by Alex Nichol on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#if TARGET_OS_IPHONE != 1

#import <Cocoa/Cocoa.h>

@class ANImageBitmapRep;

@interface NSImage (ANImageBitmapRep)

#if __has_feature(objc_arc) == 1
+ (NSImage *)imageFromImageBitmapRep:(ANImageBitmapRep *)ibr __attribute__((ns_returns_autoreleased));
- (ANImageBitmapRep *)imageBitmapRep __attribute__((ns_returns_autoreleased));
- (NSImage *)imageByScalingToSize:(CGSize)sz __attribute__((ns_returns_autoreleased));
- (NSImage *)imageFittingFrame:(CGSize)sz __attribute__((ns_returns_autoreleased));
- (NSImage *)imageFillingFrame:(CGSize)sz __attribute__((ns_returns_autoreleased));
#else
+ (NSImage *)imageFromImageBitmapRep:(ANImageBitmapRep *)ibr;
- (ANImageBitmapRep *)imageBitmapRep;
- (NSImage *)imageByScalingToSize:(CGSize)sz;
- (NSImage *)imageFittingFrame:(CGSize)sz;
- (NSImage *)imageFillingFrame:(CGSize)sz;
#endif

@end

#endif
