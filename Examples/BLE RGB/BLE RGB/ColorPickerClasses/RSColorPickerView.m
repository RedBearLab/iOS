//
//  RSColorPickerView.m
//  RSColorPicker
//
//  Created by Ryan Sullivan on 8/12/11.
//  Copyright 2011 Freelance Web Developer. All rights reserved.
//

#import "RSColorPickerView.h"
#import "BGRSLoupeLayer.h"
#import "RSSelectionView.h"
#import "RSColorFunctions.h"
#import "ANImageBitmapRep.h"
#import "RSOpacitySlider.h"
#import "RSGenerateOperation.h"

#define kSelectionViewSize 22.0

@interface RSColorPickerView () {
    struct {
        unsigned int bitmapNeedsUpdate:1;
        unsigned int badTouch:1;
		unsigned int delegateDidChangeSelection:1;
    } _colorPickerViewFlags;
}

@property (nonatomic) ANImageBitmapRep *rep;
@property (nonatomic) UIBezierPath *gradientShape;
@property (nonatomic) UIBezierPath *activeAreaShape;

@property (nonatomic) RSSelectionView *selectionView;
@property (nonatomic) UIImageView *gradientView;
@property (nonatomic) UIView *gradientContainer;
@property (nonatomic) UIView *brightnessView;
@property (nonatomic) UIView *opacityView;

@property (nonatomic) BGRSLoupeLayer *loupeLayer;
@property (nonatomic) CGPoint selection;

@property (nonatomic) CGFloat scale;

- (void)initRoutine;

- (void)genBitmap;
- (void)updateSelectionLocation;

- (CGPoint)validPointForTouch:(CGPoint)touchPoint;
- (CGPoint)convertGradientPointToView:(CGPoint)point;
- (CGPoint)convertViewPointToGradient:(CGPoint)point;

@end


@implementation RSColorPickerView

#pragma mark - Object lifecycle

- (id)initWithFrame:(CGRect)frame {
	CGFloat square = fmin(frame.size.height, frame.size.width);
	frame.size = CGSizeMake(square, square);
	
	self = [super initWithFrame:frame];
	if (self) {
		[self initRoutine];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initRoutine];
        
//        if ([aDecoder containsValueForKey:@"selectionColor"]) {
//            _selectionColor = [aDecoder decodeObjectForKey:@"selectionColor"];
//        }
//        if ([aDecoder containsValueForKey:@"cropToCircle"]) {
//            _cropToCircle = [aDecoder decodeBoolForKey:@"cropToCircle"];
//        }
    }
    return self;
}

//- (void)encodeWithCoder:(NSCoder *)aCoder {
//    [super encodeWithCoder:aCoder];
//    [aCoder encodeObject:self.selectionColor forKey:@"selectionColor"];
//    [aCoder encodeBool:self.cropToCircle forKey:@"cropToCircle"];
//}

- (void)initRoutine {
	self.opaque = YES;
	self.backgroundColor = [UIColor whiteColor];
	_colorPickerViewFlags.bitmapNeedsUpdate = NO;
	
	//the view used to select the colour
    _selectionView = [[RSSelectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSelectionViewSize, kSelectionViewSize)];
	
	_selection = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
	
	_gradientContainer = [[UIView alloc] initWithFrame:self.bounds];
	_gradientContainer.backgroundColor = [UIColor blackColor];
	_gradientContainer.clipsToBounds = YES;
	_gradientContainer.exclusiveTouch = YES;
	_gradientContainer.layer.shouldRasterize = YES;
	[self addSubview:_gradientContainer];
	
	_brightnessView = [[UIView alloc] initWithFrame:self.bounds];
	_brightnessView.backgroundColor = [UIColor blackColor];
	[_gradientContainer addSubview:_brightnessView];
	
	_gradientView = [[UIImageView alloc] initWithFrame:_gradientContainer.bounds];
	[_gradientContainer addSubview:_gradientView];
	
	UIImage *opacityBackground = RSOpacityBackgroundImage(20, [UIColor colorWithWhite:0.5 alpha:1.0]);
	_opacityView = [[UIView alloc] initWithFrame:self.bounds];
	_opacityView.backgroundColor = [UIColor colorWithPatternImage:opacityBackground];
	[_gradientContainer addSubview:_opacityView];
	
    [self updateSelectionLocationDisableActions:NO];
    [self addSubview:_selectionView];
	    
	_cropToCircle = YES;
	_selectionColor = [UIColor whiteColor];
}

- (void)dealloc {
    _loupeLayer = nil;
}

-(void)didMoveToWindow {
    if (!self.window) {
        _scale = 0;
        [_loupeLayer disappearAnimated:NO];
        return;
    }
    
    // Anything that depends on _scale to init needs to be here
    _scale = self.window.screen.scale;
    
    _gradientContainer.layer.contentsScale = _scale;
    
    _colorPickerViewFlags.bitmapNeedsUpdate = YES;
    [self genBitmap];

    self.selectionColor = _selectionColor;
    self.cropToCircle = _cropToCircle;
}

#pragma mark - Business

- (void)genBitmap {
	if (!_colorPickerViewFlags.bitmapNeedsUpdate) return;
    
    CGFloat paddingDistance = _selectionView.bounds.size.width / 2.0;
    _rep = [[self class] bitmapForDiameter:_gradientView.bounds.size.width scale:_scale padding:paddingDistance shouldCache:YES];
    
	_colorPickerViewFlags.bitmapNeedsUpdate = NO;
    _gradientView.image = RSUIImageWithScale([_rep image], _scale);
}

#pragma mark - Getters

- (UIColor*)colorAtPoint:(CGPoint)point {
    if (!_rep) return nil;
    
	CGPoint convertedPoint = [self convertViewPointToGradient:point];
	convertedPoint.x = round(convertedPoint.x);
	convertedPoint.y = round(convertedPoint.y);
	
	if (convertedPoint.x < 0) convertedPoint.x = 0;
	if (convertedPoint.x >= _gradientContainer.frame.size.width) convertedPoint.x = _gradientContainer.bounds.size.width - 1;
	if (convertedPoint.y < 0) convertedPoint.y = 0;
	if (convertedPoint.y >= _gradientContainer.bounds.size.height) convertedPoint.y = _gradientContainer.bounds.size.height - 1;
	
	BMPixel pixel = [_rep getPixelAtPoint:BMPointFromPoint(RSCGPointWithScale(convertedPoint, _scale))];
	UIColor *rgbColor = [UIColor colorWithRed:pixel.red green:pixel.green blue:pixel.blue alpha:1];
	CGFloat h, s, v;
	[rgbColor getHue:&h saturation:&s brightness:&v alpha:NULL];
	return [UIColor colorWithHue:h saturation:s brightness:_brightness alpha:_opacity];
}

#pragma mark - Setters

- (void)setBrightness:(CGFloat)bright {
	_brightness = bright;

	_gradientView.alpha = _brightness;
	[self updateSelectionAtPoint:_selection];
}

- (void)setOpacity:(CGFloat)opacity {
	_opacity = opacity;

	_opacityView.alpha = 1 - _opacity;
	[self updateSelectionAtPoint:_selection];
}


- (void)setRed:(int)value {
	_vRed = value;
}

- (void)setGreen:(int)value {
	_vGreen = value;
}

- (void)setBlue:(int)value {
	_vBlue = value;
}


- (void)setCropToCircle:(BOOL)circle {
	_cropToCircle = circle;
    
    CGRect activeAreaFrame = CGRectInset(_gradientContainer.frame, _selectionView.bounds.size.width / 2.0, _selectionView.bounds.size.height / 2.0);
    if (circle) {
        _gradientContainer.layer.cornerRadius = _gradientContainer.bounds.size.width / 2.0;
        _gradientShape = [UIBezierPath bezierPathWithOvalInRect:_gradientContainer.frame];
        _activeAreaShape = [UIBezierPath bezierPathWithOvalInRect:activeAreaFrame];
    } else {
        _gradientContainer.layer.cornerRadius = 0.0;
        _gradientShape = [UIBezierPath bezierPathWithRect:_gradientContainer.frame];
        _activeAreaShape = [UIBezierPath bezierPathWithRect:activeAreaFrame];
    }
	_selection = [self validPointForTouch:_selection];
	[self updateSelectionLocation];
}

- (void)setSelectionColor:(UIColor *)selectionColor {
	// Force color into correct colorspace to get HSV from
    float components[4];
    RSGetComponentsForColor(components, selectionColor);
    selectionColor = [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:components[3]];
  
    // convert to HSV
    CGFloat h, s, v, o;
	BOOL gotHSV = [selectionColor getHue:&h saturation:&s brightness:&v alpha:&o];
    if (!gotHSV) {
        return;
    }
    CGFloat paddingDistance = (_selectionView.bounds.size.width / 2.0) * _scale;
    
    CGFloat radius = (_rep.bitmapSize.x / 2.0);
	CGFloat angle = h * (2.0 * M_PI);
    CGFloat r_distance = s * radius;
    r_distance = fmax(fmin(r_distance, r_distance - paddingDistance), 0);
    
    CGFloat pointX = (cos(angle) * r_distance) + radius;
    CGFloat pointY = radius - (sin(angle) * r_distance);
    
    _selection = [self convertGradientPointToView:RSCGPointWithScale(CGPointMake(pointX, pointY), _scale == 0 ? 1 : 1/_scale)];
    _selectionColor = selectionColor;
    
    
    /*
     self.rgbRed = (int)(pixel.red * 255);
     self.rgbGreen= (int)(pixel.green * 255);
     self.rgbBlue = (int)(pixel.blue * 255);
     */
    
    /*
    CGFloat r,g,b;
    
    [selectionColor getRed:&r green:&g blue:&b alpha:NULL];
    
    [self setRed: r * 255];
    [self setGreen: g * 255];
    [self setBlue: b * 255];
    */
    
    [self updateSelectionLocation];
    [self setBrightness:v];
	[self setOpacity:o];
    

    
}

- (void)setDelegate:(id<RSColorPickerViewDelegate>)delegate {
	_delegate = delegate;
	_colorPickerViewFlags.delegateDidChangeSelection = [_delegate respondsToSelector:@selector(colorPickerDidChangeSelection:)];
}

#pragma mark - Selection updates

- (void)updateSelectionLocation {
    [self updateSelectionLocationDisableActions:YES];
}

- (void)updateSelectionLocationDisableActions:(BOOL)disable {
    if (disable) {
        NSDictionary *disabledActions = @{@"position" : [NSNull null], @"frame" : [NSNull null], @"center" : [NSNull null]};
        _loupeLayer.actions = disabledActions;
        _selectionView.layer.actions = disabledActions;
    }
    
	_selectionView.center = _selection;
    _loupeLayer.position = _selection;
	// Make loupeLayer sharp on screen
	CGRect loupeFrame = _loupeLayer.frame;
	loupeFrame.origin = CGPointMake(round(loupeFrame.origin.x), round(loupeFrame.origin.y));
	_loupeLayer.frame = loupeFrame;
	
	[_loupeLayer setNeedsDisplay];
    
    _loupeLayer.actions = nil;
    _selectionView.layer.actions = nil;
}

- (void)updateSelectionAtPoint:(CGPoint)point {
	CGPoint circlePoint = [self validPointForTouch:point];
	_selection = circlePoint;

    UIColor * newColor = [self colorAtPoint:circlePoint];
    if (newColor) {
        _selectionColor = newColor;
        _selectionView.selectedColor = _selectionColor;
        
        
        
        CGFloat r,g,b;
        
        [_selectionColor getRed:&r green:&g blue:&b alpha:NULL];
        
        //NSLog (@"**new %f, %f, %f", r, g, b);
        
        [self setRed: r * 255];
        [self setGreen: g * 255];
        [self setBlue: b * 255];
    }
	
	if (_colorPickerViewFlags.delegateDidChangeSelection) {
        [_delegate colorPickerDidChangeSelection:self];
    }
	
	[self updateSelectionLocation];
}

#pragma mark - Touch events

- (CGPoint)validPointForTouch:(CGPoint)touchPoint {
	if ([_activeAreaShape containsPoint:touchPoint]) {
		return touchPoint;
	}
    // We compute the right point on the gradient border
	CGPoint returnedPoint;
    
    // TouchCircle is the circle which pass by the point 'touchPoint', of radius 'r'
    // 'X' is the x coordinate of the touch in TouchCircle
    CGFloat X = touchPoint.x - CGRectGetMidX(_gradientContainer.frame);
    // 'Y' is the y coordinate of the touch in TouchCircle
    CGFloat Y = touchPoint.y - CGRectGetMidY(_gradientContainer.frame);
    CGFloat r = sqrt(pow(X, 2) + pow(Y, 2));
    
    // alpha is the angle in radian of the touch on the unit circle
    CGFloat alpha = acos( X / r );
    if (touchPoint.y > CGRectGetMidX(_gradientContainer.frame)) alpha = 2 * M_PI - alpha;
    
    // 'actual radius' is the distance between the center and the border of the gradient
    CGFloat actualRadius;
    if (_cropToCircle) {
        actualRadius = _gradientShape.bounds.size.width / 2.0 - _selectionView.bounds.size.width / 2.0;
    } else {
        // square shape - using the intercept theorem we have "actualRadius / r == 0.5*gradientContainer.height / Y"
        if ( (alpha >= M_PI_4 && alpha < 3 * M_PI_4) || (alpha >= 5 * M_PI_4 && alpha < 7 * M_PI_4) ) {
            actualRadius = r * (_gradientContainer.bounds.size.height / 2.0 - _selectionView.bounds.size.height / 2.0 ) / Y;
        } else {
            actualRadius = r * (_gradientContainer.bounds.size.width / 2.0 - _selectionView.bounds.size.width / 2.0) / X;
        }
    }
    
    returnedPoint.x = fabs(actualRadius) * cos(alpha);
    returnedPoint.y = fabs(actualRadius) * sin(alpha);
    
    // we offset the center of the circle, to get the coordinate from the right top left origin
    returnedPoint.x = returnedPoint.x + CGRectGetMidX(_gradientContainer.frame);
    returnedPoint.y = CGRectGetMidY(_gradientContainer.frame) - returnedPoint.y;
	return returnedPoint;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	// Lazily load loupeLayer
    if (!_loupeLayer) {
        _loupeLayer = [BGRSLoupeLayer layer];
    }
    [_loupeLayer appearInColorPicker:self];
	
	CGPoint point = [[touches anyObject] locationInView:self];
	[self updateSelectionAtPoint:point];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (_colorPickerViewFlags.badTouch) return;
	CGPoint point = [[touches anyObject] locationInView:self];
	[self updateSelectionAtPoint:point];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!_colorPickerViewFlags.badTouch) {
		CGPoint point = [[touches anyObject] locationInView:self];
		[self updateSelectionAtPoint:point];
	}
	_colorPickerViewFlags.badTouch = NO;
	[_loupeLayer disappear];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [_loupeLayer disappear];
}

#pragma mark - Helpers

- (CGPoint)convertGradientPointToView:(CGPoint)point {
    CGRect frame = _gradientContainer.frame;
	return CGPointMake(point.x + CGRectGetMinX(frame), point.y + CGRectGetMinY(frame));
}

- (CGPoint)convertViewPointToGradient:(CGPoint)point {
	CGRect frame = _gradientContainer.frame;
	return CGPointMake(point.x - CGRectGetMinX(frame), point.y - CGRectGetMinY(frame));
}

#pragma mark - Class methods

static NSCache *generatedBitmaps;
static NSOperationQueue *generateQueue;
static dispatch_queue_t backgroundQueue;

+(void)initialize {
    generatedBitmaps = [NSCache new];
    generateQueue = [NSOperationQueue new];
    generateQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    backgroundQueue = dispatch_queue_create("com.github.rsully.rscolorpicker.background", DISPATCH_QUEUE_SERIAL);
}

#pragma mark Background methods

+(void)prepareForDiameter:(CGFloat)diameter {
    [self prepareForDiameter:diameter padding:kSelectionViewSize/2.0];
}
+(void)prepareForDiameter:(CGFloat)diameter padding:(CGFloat)padding {
    [self prepareForDiameter:diameter scale:1.0 padding:padding];
}
+(void)prepareForDiameter:(CGFloat)diameter scale:(CGFloat)scale {
    [self prepareForDiameter:diameter scale:scale padding:kSelectionViewSize/2.0];
}
+(void)prepareForDiameter:(CGFloat)diameter scale:(CGFloat)scale padding:(CGFloat)padding {
    [self prepareForDiameter:diameter scale:scale padding:padding inBackground:YES];
}

#pragma mark Prep method

+(void)prepareForDiameter:(CGFloat)diameter scale:(CGFloat)scale padding:(CGFloat)padding inBackground:(BOOL)bg {
    void (*function)(dispatch_queue_t, dispatch_block_t) = bg ? dispatch_async : dispatch_sync;
    function(backgroundQueue, ^{
        [self bitmapForDiameter:diameter scale:scale padding:padding shouldCache:YES];
    });
}

#pragma mark Generate helper method

+(ANImageBitmapRep*)bitmapForDiameter:(CGFloat)diameter scale:(CGFloat)scale padding:(CGFloat)paddingDistance shouldCache:(BOOL)cache {
    RSGenerateOperation *repOp = nil;
    
    // Handle the scale here so the operation can just work with pixels directly
    paddingDistance *= scale;
    diameter *= scale;
    
    if (diameter <= 0) return nil;
    
    // Unique key for this size combo
    NSString *dictionaryCacheKey = [NSString stringWithFormat:@"%.1f-%.1f", diameter, paddingDistance];
    // Check cache
    repOp = [generatedBitmaps objectForKey:dictionaryCacheKey];
    
    if (repOp) {
        if (!repOp.isFinished) {
            [repOp waitUntilFinished];
        }
        return repOp.bitmap;
    }
    
    repOp = [[RSGenerateOperation alloc] initWithDiameter:diameter andPadding:paddingDistance];
    
    if (cache) {
        [generatedBitmaps setObject:repOp forKey:dictionaryCacheKey cost:diameter];
    }
    
    [generateQueue addOperation:repOp];
    [repOp waitUntilFinished];
    
    return repOp.bitmap;
}

@end
