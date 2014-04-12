//
//  ListSet.h
//  project2 part 3
//
//  Created by Tony Albor on 4/10/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ListSet : NSObject <NSCoding>

@property (strong, nonatomic) id due;
@property (strong, nonatomic) id completed;
@property (strong, nonatomic) id deleted;

@property (strong, nonatomic) NSNumber *key;

@property (strong, nonatomic) NSString *title;

@end
