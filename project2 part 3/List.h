//
//  List.h
//  project2 part 3
//
//  Created by Tony Albor on 4/15/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ListEvent;

@interface List : NSObject <NSCoding>

// dictionary of events
@property (strong, nonatomic) NSMutableDictionary *events;

// used to keep track of current category
@property (strong, nonatomic) NSNumber *currentCategory;

// store event as it is being created
@property (strong, nonatomic) ListEvent *recentlyAddedEvent;

// manage events
- (void)addEvent:(ListEvent *)event;
- (void)removeEvent:(ListEvent *)event;

// handle events for category
- (void)incrementCategory;
- (void)decrementCategory;
- (int)numberOfEventsForCurrentCategory;
- (NSArray *)eventsForCurrentCategory;

// all events
- (void)displayAllEvents;
- (BOOL)isDisplayingAllEvents;
- (NSArray *)getAllEvents;
- (int)numberOfEvents;

// TODO :: figure out if i need organization of the events
- (void)organizeEvents;

@end
