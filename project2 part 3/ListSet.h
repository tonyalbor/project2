//
//  ListSet.h
//  project2 part 3
//
//  Created by Tony Albor on 4/10/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ListEvent;

@interface ListSet : NSObject <NSCoding>

// dictionaries for where the events are stored
@property (strong, nonatomic) NSMutableDictionary *events;
@property (strong, nonatomic) NSMutableDictionary *completed;
@property (strong, nonatomic) NSMutableDictionary *deleted;

// current key used to display events
@property (strong, nonatomic) NSNumber *currentKey;

// title used to name the list set
@property (strong, nonatomic) NSString *title;

// used to keep order
// actually, not entirely sure if i need this anymore
// because i started using an array in the view controller
// to keep everything ordered there. but for now, im just
// gonna leave it here
@property (strong, nonatomic) ListEvent *recentlyAddedEvent;

// returns the filename to read from and write to
- (NSString *)fileName;

// manage events
- (void)addEvent:(ListEvent *)event;
- (void)completeEvent:(ListEvent *)event;
- (void)deleteEvent:(ListEvent *)event;

// handle events for current key
- (NSNumber *)currentKey;
- (void)incrementKey;
- (void)decrementKey;
- (int)numberOfEventsForCurrentKey;
- (NSMutableArray *)eventsForCurrentKey;

// all events
- (NSMutableArray *)getAllEventsForList:(NSMutableDictionary *)list;
- (void)displayAllEvents;
- (BOOL)isDisplayingAllEvents;

// helper functions

// do I need this?
- (void)organizeEvents;

@end
