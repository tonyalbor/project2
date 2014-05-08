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

@property (strong, nonatomic) NSNumber *currentKey;

@property (strong, nonatomic) NSNumber *recentlyAddedSet;

// data source
+ (ListSetDataSource *)sharedDataSource;

// returns prefix for file name for data source
- (NSString *)prefixFileName;

// adding/removing sets
- (void)addSet:(ListSet *)set;
- (void)removeSet:(ListSet *)set;

// current key stuff
- (id)currentKey;
- (void)incrementKey;
- (void)decrementKey;
- (ListSet *)listSetForCurrentKey;

// all sets
- (NSArray *)getAllSets;

@end