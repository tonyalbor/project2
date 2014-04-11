//
//  ListSet.h
//  project2 part 3
//
//  Created by Tony Albor on 4/10/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ListSet : NSObject

@property (strong, nonatomic) id due;
@property (strong, nonatomic) id completed;
@property (strong, nonatomic) id deleted;

// will be used for title of list set
@property (strong, nonatomic) id key;

@end
