//
//  CGImageContainer.h
//  ImageBitmapRep
//
//  Created by Alex Nichol on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#if __has_feature(objc_arc) != 1

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <CoreGraphics/CoreGraphics.h>
#elif TARGET_OS_MAC
#import <Quartz/Quartz.h>
#endif


@interface CGImageContainer : NSObject {
    CGImageRef image;
}

/**
 * The image that this container encloses.
 */
@property (readonly) CGImageRef image;

/**
 * Create a new image container with an image.
 * @param anImage Will be retained and enclosed in this class.
 * This object will be released when the CGImageContainer is
 * deallocated.  This can be nil.
 * @return The new image container, or nil if anImage is nil.
 */
- (id)initWithImage:(CGImageRef)anImage;

/**
 * Create a new image container with an image.
 * @param anImage Will be retained and enclosed in this class.
 * This object will be released when the CGImageContainer is
 * deallocated.  This can be nil.
 * @return The new image container, or nil if anImage is nil.
 * The image container returned will be autoreleased.
 */
+ (CGImageContainer *)imageContainerWithImage:(CGImageRef)anImage;

@end

#else

id CGImageReturnAutoreleased (CGImageRef original) __attribute__((ns_returns_autoreleased));

#endif
