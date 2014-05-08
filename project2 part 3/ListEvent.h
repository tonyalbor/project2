//
//  ListEvent.h
//  project2 part 3
//
//  Created by Tony Albor on 9/8/13.
//  Copyright (c) 2013 tonyalbor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ListEvent : NSObject <NSCoding>

// event title
@property (strong, nonatomic) NSString *title;

// string value of date
@property (strong, nonatomic) NSString *dateString;

// event date
@property (strong, nonatomic) NSDate *date;

// category id for color
@property (strong, nonatomic) NSNumber *categoryID;
@property (strong, nonatomic) NSNumber *sortId;

- (void)changeColor;

@end
