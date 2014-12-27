//
//  CustomCellColor.m
//  project2 part 3
//
//  Created by Tony Albor on 9/8/13.
//  Copyright (c) 2013 tonyalbor. All rights reserved.
//

/*
 *  Adding colors:
 *
 *  To add a color, create a setColorN method for it;
 *  give it a key one more than the previous one;
 *  +initializeColors will automatically add it;
 *
 **/

// MAJOR TODO :: improve system to handle themes

#import "CustomCellColor.h"

@implementation CustomCellColor

@synthesize red,blue,green;

static NSMutableDictionary *_customColors = nil;

- (UIColor *)customCellColorToUIColor {
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

+ (CustomCellColor *)colorForId:(NSNumber *)index {
    return (CustomCellColor *)[_customColors objectForKey:index];
}

+ (CustomCellColor *)lightColorForId:(NSNumber *)index {
	// rt = r + (0.25 * (255 - r))
	CustomCellColor *color = [self colorForId:index];
	color.red += 1/4 * (255 - color.red);
	color.green += 1/4 * (255 - color.green);
	color.blue += 1/4 * (255 - color.blue);
	return color;
}

+ (CustomCellColor *)darkColorForId:(NSNumber *)index {
	CustomCellColor *color = [self colorForId:index];
	CustomCellColor *dark = [self newColorWithRed:color.red*0.85 blue:color.blue*0.85 green:color.green*0.85 andIndex:@999];
	return dark;
}

+ (UIColor *)lightColorForUIColor:(UIColor *)color {
    for(id key in _customColors) {
        CustomCellColor *customColor = [_customColors objectForKey:key];
        if([customColor isEqualToColor:color])
            return [[CustomCellColor lightColorForId:key] customCellColorToUIColor];
//            return [customColor customCellColorToUIColor];
    }
    return [UIColor whiteColor];
}

- (BOOL)isEqualToColor:(UIColor *)color {
    CGFloat colorRed, colorGreen, colorBlue;
    CGFloat one = 1.0f;
    [color getRed:&colorRed green:&colorGreen blue:&colorBlue alpha:&one];
    return red == colorRed && green == colorGreen && blue == colorBlue;
}

// set up custom colors array
+ (void)initializeColors {
    _customColors = [[NSMutableDictionary alloc] init];
    for(int i = 0; [self respondsToSelector:NSSelectorFromString([NSString stringWithFormat:@"setColor%d",i])]; ++i) {
        [self performSelectorInBackground:NSSelectorFromString([NSString stringWithFormat:@"setColor%d",i]) withObject:nil];
    }
}

+ (BOOL)colorExistsForCategoryId:(NSNumber *)category {
    return [[_customColors allKeys] containsObject:category];
}

/*

 retired
 
+ (CustomCellColor *)whiteColor {
    return [self newColorWithRed:1 blue:1 green:1 andIndex:@0];
}

*/

#define WHITE_KEY @(-1)

+ (void)setColorNegativeOne {
    id color = [self newColorWithRed:1 blue:1 green:1 andIndex:WHITE_KEY];
    [_customColors setObject:color forKey:WHITE_KEY];
}

#define RED_KEY @0 // === RED ============================

+ (void)setColor0 {
    id color = [self newColorWithRed:1 blue:.4 green:.4 andIndex:RED_KEY];
    [_customColors setObject:color forKey:RED_KEY];
}

+ (CustomCellColor *)redColor {
    return [_customColors objectForKey:RED_KEY];
}

#define BLUE_KEY @1 // === BLUE ==========================

+ (void)setColor1 {
    id color = [self newColorWithRed:.4 blue:1 green:.8 andIndex:BLUE_KEY];
    [_customColors setObject:color forKey:BLUE_KEY];
}

+ (CustomCellColor *)blueColor {
    return [_customColors objectForKey:BLUE_KEY];
}

#define GREEN_KEY @2 // === GREEN ========================

+ (void)setColor2 {
    id color = [self newColorWithRed:.4 blue:.8 green:1 andIndex:GREEN_KEY];
    [_customColors setObject:color forKey:GREEN_KEY];
}

+ (CustomCellColor *)greenColor {
    return [_customColors objectForKey:GREEN_KEY];
}

#define YELLOW_KEY @3 // === YELLOW ======================

+ (void)setColor3 {
    id color = [self newColorWithRed:1 blue:.4 green:1 andIndex:YELLOW_KEY];
    [_customColors setObject:color forKey:YELLOW_KEY];
}

+ (CustomCellColor *)yellowColor {
    return [_customColors objectForKey:YELLOW_KEY];
}

#define PURPLE_KEY @4 // === PURPLE ======================

+ (void)setColor4 {
    id color = [self newColorWithRed:.8 blue:1 green:.4 andIndex:PURPLE_KEY];
    [_customColors setObject:color forKey:PURPLE_KEY];
}

+ (CustomCellColor *)purpleColor {
    return [_customColors objectForKey:PURPLE_KEY];
}

#define PINK_KEY @5 // === PINK ==========================

+ (void)setColor5 {
    id color = [self newColorWithRed:1 blue:.8 green:.4 andIndex:PINK_KEY];
    [_customColors setObject:color forKey:PINK_KEY];
}

+ (CustomCellColor *)pinkColor {
    return  [_customColors objectForKey:PINK_KEY];
}

#define ORANGE_KEY @6 // === ORANGE ======================

+ (void)setColor6 {
    id color = [self newColorWithRed:1 blue:.4 green:.8 andIndex:ORANGE_KEY];
    [_customColors setObject:color forKey:ORANGE_KEY];
}

+ (CustomCellColor *)orangeColor {
    return [_customColors objectForKey:ORANGE_KEY];
}

#define ORCHID_KEY @7 // === ORCHID ======================

+ (void)setColor7 {
    id color = [self newColorWithRed:.4 blue:1 green:.4 andIndex:ORCHID_KEY];
    [_customColors setObject:color forKey:ORCHID_KEY];
}

+ (CustomCellColor *)orchidColor {
    return [_customColors objectForKey:ORCHID_KEY];
}
/*
#define TEST_KEY @8

+ (void)setColor8 {
    id color = [self newColorWithRed:.1 blue:.3 green:.4 andIndex:TEST_KEY];
    [_customColors setObject:color forKey:TEST_KEY];
}
 */

// ========================================================

+ (NSNumber *)numberOfCustomColors {
    return @([[_customColors allKeys] count] - 1); // minus one for white
}

#pragma mark private

+ (CustomCellColor *)newColorWithRed:(CGFloat)redFloat blue:(CGFloat)blueFloat green:(CGFloat)greenFloat andIndex:(NSNumber *)index {
    CustomCellColor *color = [CustomCellColor new];
    color.red = redFloat;
    color.blue = blueFloat;
    color.green = greenFloat;
    color.index = index;
    return color;
}
/*
+ (NSArray *)customColors {
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    for(int i = 0; i < _customColors.allKeys.count; ++i) {
        [colors addObject:[_customColors objectForKey:key]];
    }
    return _customColors;
}
 */

@end
