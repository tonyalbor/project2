//
//  ListEventDataSource.m
//  project2 part 3
//
//  Created by Tony Albor on 9/8/13.
//  Copyright (c) 2013 tonyalbor. All rights reserved.
//

#import "ListEventDataSource.h"
#import "ListEvent.h"

#define ListEventDataSourceFile @"to-do.txt"

@implementation ListEventDataSource

@synthesize recentlyAddedEvent;

static ListEventDataSource *_sharedDataSource = nil;

+ (ListEventDataSource *)sharedDataSource {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataSource = [[ListEventDataSource alloc] init];
        _sharedDataSource.recentlyAddedEvent = nil;
    });
    
    return _sharedDataSource;
}

- (NSString *)fileName {
    return ListEventDataSourceFile;
}

- (NSMutableArray *)getAllEvents {
    NSMutableArray *allEvents = [[NSMutableArray alloc] init];
    ListEvent *currentEvent;
    NSArray *array;
    for(NSNumber *key in _events) {
        array = [_events objectForKey:key];
        for(int i = 0; i < array.count; ++i) {
            currentEvent = [array objectAtIndex:i];
            if(currentEvent != recentlyAddedEvent) {
                [allEvents addObject:currentEvent];
            }
        }
    }
    if(recentlyAddedEvent) [allEvents addObject:recentlyAddedEvent];
    return allEvents;
}

- (void)addEvent:(ListEvent *)event {
    if(_events == nil) {
        // initialize map table
        NSLog(@"what");
        _events = [[NSMapTable alloc] init];
    }
    if(_currentKey == nil) _currentKey = @0;
    NSLog(@"list key: %@",_currentKey);
    event.categoryID = [self isDisplayingAllEvents] ? @0 : _currentKey;
    
    if([_events objectForKey:event.categoryID] == nil) {
        // initialize array
        [_events setObject:[[NSMutableArray alloc] init] forKey:event.categoryID];
    }
    [event setSortId:@([[_events objectForKey:event.categoryID] count])];
    [[_events objectForKey:event.categoryID] addObject:event];
    
    recentlyAddedEvent = event;
}

- (void)removeEvent:(ListEvent *)eventToBeRemoved {
    // just go through it all to find it
    for(NSNumber *key in _events) {
        [[_events objectForKey:key] removeObject:eventToBeRemoved];
    }
    
}

- (void)removeEventAtIndexPath:(NSIndexPath *)indexPath {
    [[_events objectForKey:_currentKey] removeObjectAtIndex:indexPath.row];
}

- (ListEvent *)eventForIndexPath:(NSIndexPath *)indexPath {
    return [[_events objectForKey:_currentKey] objectAtIndex:indexPath.row];
}

- (void)organizeEvents {
    NSMutableDictionary *temp = [self mapToDictionary:_events];
    [_events removeAllObjects];
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
            if([_events objectForKey:eventKey] == nil) {
                [_events setObject:[[NSMutableArray alloc] init] forKey:eventKey];
            }
            
            // add current event to events with its ID
            [[_events objectForKey:eventKey] addObject:currentEvent];
        }
    }
}

@end
