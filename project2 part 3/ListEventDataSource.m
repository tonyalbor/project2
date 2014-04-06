//
//  ListEventDataSource.m
//  project2 part 3
//
//  Created by Tony Albor on 9/8/13.
//  Copyright (c) 2013 tonyalbor. All rights reserved.
//

#import "ListEventDataSource.h"
#import "ListEvent.h"
#import "MemoryDataSource.h"

#define ListEventDataSourceFile @"to-do.txt"

@implementation ListEventDataSource

@synthesize events;
@synthesize eventsAddedToAll;
@synthesize currentKey;

static ListEventDataSource *_sharedDataSource = nil;

+ (ListEventDataSource *)sharedDataSource {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataSource = [[ListEventDataSource alloc] init];
        
        // weird hack for just-added items to list
        _sharedDataSource.eventsAddedToAll = [[NSMutableArray alloc] init];
    });
    
    return _sharedDataSource;
}

- (NSString *)fileName {
    return ListEventDataSourceFile;
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
    for(int i = 0; i < eventsAddedToAll.count; ++i) {
        ListEvent *currentEvent = [eventsAddedToAll objectAtIndex:i];
        [allEvents addObject:currentEvent];
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
        totalNumberOfEvents += eventsAddedToAll.count;
        return totalNumberOfEvents;
    }
    return [[events objectForKey:currentKey] count];
}

- (ListEvent *)recentlyAddedEvent {
    if([self isDisplayingAllEvents]) {
        if(eventsAddedToAll.count > 0) {
            return [eventsAddedToAll objectAtIndex:eventsAddedToAll.count-1];
        }
    }
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

    if([self isDisplayingAllEvents]) {
        if(eventsAddedToAll == nil) {
            eventsAddedToAll = [[NSMutableArray alloc] init];
        }
        newEvent.categoryID = @0;
        [eventsAddedToAll addObject:newEvent];
        NSLog(@"count of added to all: %d",eventsAddedToAll.count);
        return;
    }
    
    if([events objectForKey:currentKey] == nil) {
        // initialize array
        [events setObject:[[NSMutableArray alloc] init] forKey:currentKey];
    }
    [[events objectForKey:currentKey] addObject:newEvent];
}

- (void)removeEvent:(ListEvent *)eventToBeRemoved {
    // key for color
    NSNumber *key = eventToBeRemoved.categoryID;
    
    // get all events of the same color
    NSArray *eventsForKey = [events objectForKey:key];
    
    // go through events of same color
    for(int i = 0; i < eventsForKey.count; ++i) {
        //NSLog(@"%@",eventToBeRemoved.title);
        if([eventToBeRemoved isEqual:[eventsForKey objectAtIndex:i]]) {
            // if eventToBeRemoved is found, then remove it
            [[events objectForKey:key] removeObjectAtIndex:i];
            return;
        }
    }
    
    // if method hasn't returned, that means the event is in eventsAddedToAll
    for(int i = 0; i < eventsAddedToAll.count; ++i) {
        if([eventToBeRemoved isEqual:[eventsAddedToAll objectAtIndex:i]]) {
            [eventsAddedToAll removeObjectAtIndex:i];
            return;
        }
    }
    
    // if still not found, just go through it all to find it
    for(NSNumber *key in events) {
        [[events objectForKey:key] removeObject:eventToBeRemoved];
    }
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

- (void)changeKeyFor:(ListEvent *)event fromKey:(NSNumber *)before toKey:(NSNumber *)after {
    // get all events for the same before color
    NSArray *eventsForOldKey = [events objectForKey:before];
    
    // find it in events and remove it
    for(ListEvent *eventEnum in eventsForOldKey) {
        if([event isEqual:eventEnum]) {
            [[events objectForKey:before] removeObject:event];
        }
    }
    
    // initialize array if nil
    if(![events objectForKey:after]) {
        [events setObject:[NSMutableArray new] forKey:after];
    }
    
    // place event in after key
    [[events objectForKey:after] addObject:event];
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
            if(eventKey == nil) eventKey = @0;
            
            // it there is no key in events that matches the event key,
            // create a new array for it
            if([events objectForKey:eventKey] == nil) {
                [events setObject:[[NSMutableArray alloc] init] forKey:eventKey];
            }
            
            // add current event to events with its ID
            [[events objectForKey:eventKey] addObject:currentEvent];
        }
    }
    if(eventsAddedToAll.count > 0) {
        //[events setObject:[[NSMutableArray alloc] init] forKey:@0];
        for(int i = 0; i < eventsAddedToAll.count; ++i) {
            ListEvent *event = [eventsAddedToAll objectAtIndex:i];
            NSNumber *key = event.categoryID;
            if([events objectForKey:key] == nil) [events setObject:[[NSMutableArray alloc] init] forKey:key];
            [[events objectForKey:key] addObject:event];
        }
        [eventsAddedToAll removeAllObjects];
    }
}

- (BOOL)isDisplayingAllEvents {
    return [currentKey isEqualToNumber:@99];
}

@end
