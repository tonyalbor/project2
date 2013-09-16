//
//  ListEvent.h
//  project2 part 3
//
//  Created by Tony Albor on 9/8/13.
//  Copyright (c) 2013 tonyalbor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ListEvent : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSNumber *categoryID;

- (void)changeColor;

@end
