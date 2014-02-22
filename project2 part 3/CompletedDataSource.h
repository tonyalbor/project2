//
//  CompletedDataSource.h
//  project2 part 3
//
//  Created by Tony Albor on 2/10/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ListEvent;

@interface CompletedDataSource : NSObject

+ (CompletedDataSource *)sharedDataSource;

@property (strong, nonatomic) NSMapTable *events;

@property (strong, nonatomic) NSNumber *currentKey;

- (void)completeEvent:(ListEvent *)event;

- (NSMutableArray *)getAllEvents;
- (BOOL)isDisplayingAllEvents;
- (int)numberOfEventsForCurrentKey;

- (void)incrementKey;
- (void)decrementKey;

- (void)displayAllEvents;

- (NSArray *)eventsForCurrentKey;

- (void)organizeEvents;

@end
