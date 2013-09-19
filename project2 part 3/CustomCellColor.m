//
//  CustomCellColor.m
//  project2 part 3
//
//  Created by Tony Albor on 9/8/13.
//  Copyright (c) 2013 tonyalbor. All rights reserved.
//

#import "CustomCellColor.h"

@implementation CustomCellColor

@synthesize red,blue,green;

- (UIColor *)customCellColorToUIColor {
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

+ (CustomCellColor *)newColorWithRed:(CGFloat)redFloat blue:(CGFloat)blueFloat green:(CGFloat)greenFloat andIndex:(NSNumber *)index {
    CustomCellColor *color = [CustomCellColor new];
    color.red = redFloat;
    color.blue = blueFloat;
    color.green = greenFloat;
    color.index = index;
    return color;
}

+ (CustomCellColor *)colorForId:(NSNumber *)index {
    return [[self customColors] objectAtIndex:index.integerValue];
}

+ (CustomCellColor *)whiteColor {
    return [self newColorWithRed:1 blue:1 green:1 andIndex:@0];
}

+ (CustomCellColor *)redColor {
    return [self newColorWithRed:1 blue:.4 green:.4 andIndex:@1];
}

+ (CustomCellColor *)blueColor {
    return [self newColorWithRed:.4 blue:1 green:.8 andIndex:@2];
}

+ (CustomCellColor *)greenColor {
    return [self newColorWithRed:.4 blue:.8 green:1 andIndex:@3];
}

+ (CustomCellColor *)yellowColor {
    return [self newColorWithRed:1 blue:.4 green:1 andIndex:@4];
}

+ (CustomCellColor *)purpleColor {
    return [self newColorWithRed:.8 blue:1 green:.4 andIndex:@5];
}

+ (CustomCellColor *)pinkColor {
    return [self newColorWithRed:1 blue:.8 green:.4 andIndex:@6];
}

+ (CustomCellColor *)orangeColor {
    return [self newColorWithRed:1 blue:.4 green:.8 andIndex:@7];
}

+ (CustomCellColor *)orchidColor {
    return [self newColorWithRed:.4 blue:1 green:.4 andIndex:@8];
}

+ (NSArray *)customColors {
    return @[[self whiteColor],
             [self redColor],
             [self blueColor],
             [self greenColor],
             [self yellowColor],
             [self purpleColor],
             [self pinkColor],
             [self orangeColor],
             [self orchidColor]];
}

@end
