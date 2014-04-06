//
//  ListEventDataSource.h
//  project2 part 3
//
//  Created by Tony Albor on 9/8/13.
//  Copyright (c) 2013 tonyalbor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventDataSource.h"

@class ListEvent;
@class MemoryDataSource;

@interface ListEventDataSource : EventDataSource

// key: NSNumber id for CustomCellColor
// object: NSMutableArray containing events for key
@property (strong, nonatomic) NSMapTable *events;
// -------------------------------------------------

@property (strong, nonatomic) NSMutableArray *eventsAddedToAll;

// current key used to display events
@property (strong, nonatomic) NSNumber *currentKey;

// datasource
+ (ListEventDataSource *)sharedDataSource;

// file name to read from and write to
- (NSString *)fileName;

- (NSMutableArray *)eventsForCurrentKey;
- (NSInteger)numberOfEventsForCurrentKey;
- (ListEvent *)recentlyAddedEvent;

- (void)addEvent:(ListEvent *)newEvent;
- (void)removeEvent:(ListEvent *)eventToBeRemoved;
- (void)removeEventAtIndexPath:(NSIndexPath *)indexPath;

- (ListEvent *)eventForIndexPath:(NSIndexPath *)indexPath;

- (void)incrementCurrentKey;
- (void)decrementCurrentKey;

- (void)changeKeyFor:(ListEvent *)event fromKey:(NSNumber *)before toKey:(NSNumber *)after;

- (void)organizeEvents;
- (NSMutableArray *)getAllEvents;
- (void)displayAllEvents;

- (BOOL)isDisplayingAllEvents;

- (NSMutableDictionary *)mapToDictionary:(NSMapTable *)map;

@end
