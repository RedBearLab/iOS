//
//  OSCommonImage.c
//  ImageBitmapRep
//
//  Created by Alex Nichol on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#include "OSCommonImage.h"

CGImageRef CGImageFromANImage (ANImageObj * anImageObj) {
#if TARGET_OS_IPHONE
	return [anImageObj CGImage];
#elif TARGET_OS_MAC
	CGImageSourceRef source;
#if __has_feature(objc_arc) == 1
	source = CGImageSourceCreateWithData((__bridge CFDataRef)[anImageObj TIFFRepresentation], NULL);
#else
	source = CGImageSourceCreateWithData((CFDataRef)[anImageObj TIFFRepresentation], NULL);
#endif
	CGImageRef maskRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
	CFRelease(source);
#if __has_feature(objc_arc) == 1
	CGImageRef autoreleased = (__bridge CGImageRef)CGImageReturnAutoreleased(maskRef);
	CGImageRelease(maskRef);
	return autoreleased;
#else
	CGImageContainer * container = [CGImageContainer imageContainerWithImage:maskRef];
	CGImageRelease(maskRef);
	return [container image];
#endif
#endif
}

ANImageObj * ANImageFromCGImage (CGImageRef imageRef) {
#if TARGET_OS_IPHONE
	return [UIImage imageWithCGImage:imageRef];
#elif TARGET_OS_MAC
	NSImage * image = [[NSImage alloc] initWithCGImage:imageRef size:NSZeroSize];
#if __has_feature(objc_arc) == 1
	return image;
#else
	return [image autorelease];
#endif
#endif
}
