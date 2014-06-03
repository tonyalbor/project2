//
//  CustomCellColor.h
//  project2 part 3
//
//  Created by Tony Albor on 9/8/13.
//  Copyright (c) 2013 tonyalbor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomCellColor : NSObject

@property (nonatomic) CGFloat red;
@property (nonatomic) CGFloat blue;
@property (nonatomic) CGFloat green;

@property (strong, nonatomic) NSNumber *index;

// initialize colors
+ (void)initializeColors;

// get uicolor from customcellcolor
- (UIColor *)customCellColorToUIColor;

+ (BOOL)colorExistsForCategoryId:(id)key;

// get customcellcolor
+ (CustomCellColor *)colorForId:(NSNumber *)index;
+ (CustomCellColor *)redColor;
+ (CustomCellColor *)blueColor;
+ (CustomCellColor *)greenColor;
+ (CustomCellColor *)yellowColor;
+ (CustomCellColor *)purpleColor;
+ (CustomCellColor *)pinkColor;
+ (CustomCellColor *)orangeColor;
+ (CustomCellColor *)orchidColor;
//+ (CustomCellColor *)whiteColor;

// get number of colors
+ (NSNumber *)numberOfCustomColors;

@end
