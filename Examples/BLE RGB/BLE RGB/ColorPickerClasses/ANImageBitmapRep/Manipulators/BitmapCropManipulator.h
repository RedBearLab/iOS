//
//  CroppableBitmapRep.h
//  ImageManip
//
//  Created by Alex Nichol on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BitmapContextManipulator.h"

@protocol BitmapCropManipulator

@optional
- (void)cropFrame:(CGRect)frame;
- (void)cropTopFrame:(CGRect)frame;
- (void)cropTopEllipse:(CGRect)frame;
- (CGImageRef)croppedImageWithFrame:(CGRect)frame;

@end

@interface BitmapCropManipulator : BitmapContextManipulator {
    
}

/**
 * Cuts a part of the bitmap out for a new bitmap.
 * @param frame The rectangle from which a portion of the image will
 * be cut.
 * The coordinates for this start at (0,0).
 * @discussion The coordinates for this method begin in the bottom
 * left corner.  For a coordinate system starting from the top
 * left corner, use cropTopFrame: instead.
 */
- (void)cropFrame:(CGRect)frame;

/**
 * Cuts a part of the bitmap out for a new bitmap.
 * @param frame The rectangle from which a portion of the image will
 * be cut.
 * The coordinates for this start at (0,0).
 * @discussion The coordinates for this method begin in the top
 * left corner.  For a coordinate system starting from the bottom
 * left corner, use cropFrame: instead.
 */
- (void)cropTopFrame:(CGRect)frame;

/**
 * Cuts an ellipse of the bitmap out for a new bitmap.
 * @param frame The rectangle around the ellipse to be cut. The
 * coordinates for this start at (0,0).
 * @discussion The coordinates for this method begin in the top
 * left corner.  There is no alternative.
 */
- (void)cropTopEllipse:(CGRect)frame;

/**
 * Creates a new CGImageRef by cutting out a portion of this one.
 * This takes its behavoir from cropFrame.
 * @return An autoreleased CGImageRef that has been cropped from this
 * image.
 */
- (CGImageRef)croppedImageWithFrame:(CGRect)frame;

@end
