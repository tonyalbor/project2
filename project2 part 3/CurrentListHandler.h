//
//  CurrentListHandler.h
//  project2 part 3
//
//  Created by Tony Albor on 2/12/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ListSet;

@interface CurrentListHandler : NSObject

// shared data source to be used throughout the entire app
+ (CurrentListHandler *)sharedDataSource;

// 0 - deleted
// 1 - events
// 2 - completed
@property (strong, nonatomic) NSNumber *currentList;

// returns the data source for the current list
- (NSDictionary *)currentListForSet:(ListSet *)set;

- (BOOL)isInEvents;
- (BOOL)isInCompleted;
- (BOOL)isInDeleted;

@end
