//
//  ListEventDataSource.m
//  project2 part 3
//
//  Created by Tony Albor on 9/8/13.
//  Copyright (c) 2013 tonyalbor. All rights reserved.
//

#import "ListEventDataSource.h"

@implementation ListEventDataSource

@synthesize events;
@synthesize currentKey;

static ListEventDataSource *_sharedDataSource = nil;

+ (ListEventDataSource *)sharedDataSource {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataSource = [[ListEventDataSource alloc] init];
        _sharedDataSource.currentKey = @0;
    });
    return _sharedDataSource;
}

- (void)reloadEventsForCurrentKey {
    
}

- (NSMutableArray *)getAllEvents {
    NSMutableArray *allEvents = [[NSMutableArray alloc] init];
    ListEvent *currentEvent;
    NSArray *array;
    for(NSNumber *key in events) {
        array = [events objectForKey:key];
        for(int i = 0; i < array.count; ++i) {
            currentEvent = [array objectAtIndex:i];
            [allEvents addObject:currentEvent];
        }
    }
    return allEvents;
}

- (NSMutableArray *)eventsForCurrentKey {
    return [events objectForKey:currentKey];
}

- (NSInteger)numberOfEventsForCurrentKey {
    if([self isDisplayingAllEvents]) {
        NSInteger totalNumberOfEvents = 0;
        for(NSNumber *key in events) {
            NSArray *array = [events objectForKey:key];
            totalNumberOfEvents += array.count;
        }
        return totalNumberOfEvents;
    }
    return [[events objectForKey:currentKey] count];
}

- (ListEvent *)recentlyAddedEvent {
    NSArray *eventsForKey = [events objectForKey:currentKey];
    NSInteger numOfEvents = eventsForKey.count;
    return [eventsForKey objectAtIndex:numOfEvents - 1];
}

- (void)addEvent:(ListEvent *)newEvent {
    if(events == nil) {
        // initialize map table
        NSLog(@"what");
        events = [[NSMapTable alloc] init];
    }
    if(currentKey == nil) currentKey = @0;
    /*
    if([self isDisplayingAllEvents]) {
        if([events objectForKey:@0] == nil) [events setObject:[[NSMutableArray alloc] init] forKey:@0];
        [[events objectForKey:@0] addObject:newEvent];
        [self organizeEvents];
        //[events setObject:newEvent forKey:@0];
        return;
    }
     */
    if([events objectForKey:currentKey] == nil) {
        NSLog(@"init");
        // initialize array
        [events setObject:[[NSMutableArray alloc] init] forKey:currentKey];
    }
    [[events objectForKey:currentKey] addObject:newEvent];
}

- (void)removeEventAtIndexPath:(NSIndexPath *)indexPath {
    [[events objectForKey:currentKey] removeObjectAtIndex:indexPath.row];
}

- (ListEvent *)eventForIndexPath:(NSIndexPath *)indexPath {
    return [[events objectForKey:currentKey] objectAtIndex:indexPath.row];
}

- (void)displayAllEvents {
    currentKey = @99;
}

- (void)incrementCurrentKey {
    if([self isDisplayingAllEvents]) currentKey = @0;
    else if([currentKey isEqualToNumber:@8]) currentKey = @0;
    else {
        NSInteger temp = currentKey.integerValue;
        ++temp;
        currentKey = [NSNumber numberWithInteger:temp];
    }
    if([[events objectForKey:currentKey] count] == 0) [self incrementCurrentKey];
}

- (void)decrementCurrentKey {
    if([self isDisplayingAllEvents]) currentKey = @8;
    else if([currentKey isEqualToNumber:@0]) currentKey = @8;
    else {
        NSInteger temp = currentKey.integerValue;
        --temp;
        currentKey = [NSNumber numberWithInteger:temp];
    }
    if([[events objectForKey:currentKey] count] == 0) [self decrementCurrentKey];
}

- (NSMutableDictionary *)mapToDictionary:(NSMapTable *)map {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    for(NSNumber *key in map) {
        [dictionary setObject:[[NSMutableArray alloc] init] forKey:key];
        NSArray *array = [map objectForKey:key];
        ListEvent *event = [[ListEvent alloc] init];
        for(int i = 0; i < array.count; ++i) {
            event = [array objectAtIndex:i];
            [[dictionary objectForKey:key] addObject:event];
        }
    }
    return dictionary;
}

- (void)organizeEvents {
    NSMutableDictionary *temp = [self mapToDictionary:events];
    [events removeAllObjects];
    ListEvent *currentEvent = [[ListEvent alloc] init];
    NSNumber *eventKey;
    
    // go through all 'keys' in events
    for(NSNumber *key in temp) {
        // go through each of the arrays
        NSArray *array = [temp objectForKey:key];
        for(int i = 0; i < array.count; ++i) {
            // grab the event and its ID
            currentEvent = [array objectAtIndex:i];
            eventKey = currentEvent.categoryID;
            
            // it there is no key in events that matches the event key,
            // create a new array for it
            if([events objectForKey:eventKey] == nil) {
                [events setObject:[[NSMutableArray alloc] init] forKey:eventKey];
            }
            
            // add current event to events with its ID
            [[events objectForKey:eventKey] addObject:currentEvent];
        }
    }
}

- (BOOL)isDisplayingAllEvents {
    return [currentKey isEqualToNumber:@99];
}

@end
