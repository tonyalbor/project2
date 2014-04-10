//
//  ListSetDataSource.h
//  project2 part 3
//
//  Created by Tony Albor on 4/10/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ListSet;

@interface ListSetDataSource : NSObject

@property (strong, nonatomic) NSMutableDictionary *sets;

// data source
+ (ListSetDataSource *)sharedDataSource;

- (void)addSet:(ListSet *)set;
- (void)removeSet:(ListSet *)set;

@end
