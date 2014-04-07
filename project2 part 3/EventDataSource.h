//
//  EventDataSource.h
//  project2 part 3
//
//  Created by Tony Albor on 4/5/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ListEvent;
@class ListEventDataSource;
@interface EventDataSource : NSObject {
    NSMapTable *_events;
    NSNumber *_currentKey;
}

// key: NSNumber id for CustomCellColor
// object: NSMutableArray containing events for key
@property (strong, nonatomic) NSMapTable *events;
// -------------------------------------------------

// current key used to display events
@property (strong, nonatomic) NSNumber *currentKey;

// data source
+ (id)sharedDataSource;

// file name to read from and write to
- (NSString *)fileName;

// modifying events
- (void)addEvent:(ListEvent *)event;

// sort id stuff
- (ListEvent *)eventForSortId:(NSInteger)sort;

// current key stuff
- (void)incrementKey;
- (void)decrementKey;
- (NSNumber *)currentKey;
- (int)numberOfEventsForCurrentKey;
- (NSMutableArray *)eventsForCurrentKey;

// all events
- (NSMutableArray *)getAllEvents;
- (void)displayAllEvents;
- (BOOL)isDisplayingAllEvents;

// helper stuff
- (NSMutableDictionary *)mapToDictionary:(NSMapTable *)map;
- (void)organizeEvents;

@end
