//
//  EventDataSource.m
//  project2 part 3
//
//  Created by Tony Albor on 4/5/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import "EventDataSource.h"
#import "ListEvent.h"
#import "MemoryDataSource.h"
#import "ListEventDataSource.h"

@implementation EventDataSource

+ (id)sharedDataSource {
    return nil;
}

- (NSString *)fileName {
    return nil;
}

- (void)addEvent:(ListEvent *)event {
    // set events if nil
    if(!_events) _events = [[NSMapTable alloc] init];
    
    // make sure there is a key set
    if(!event.categoryID) _currentKey = @0;
    else _currentKey = event.categoryID;
    
    // initialize array if nil
    if(![_events objectForKey:_currentKey]) {
        [_events setObject:[NSMutableArray new] forKey:_currentKey];
    }
    
    event.sortId = @([[_events objectForKey:_currentKey] count]);
    // add event to data source
    [[_events objectForKey:_currentKey] addObject:event];
}

- (ListEvent *)eventForSortId:(NSInteger)sort {
    BOOL allEventsShown = [self isDisplayingAllEvents];
    
    NSArray *eventsDisplayed = allEventsShown ? [self getAllEvents] : [_events objectForKey:_currentKey];
    for(ListEvent *event in eventsDisplayed) {
        if([event.sortId isEqualToNumber:@(sort)]) return event;
    }
    
    return nil;
}

- (NSMutableArray *)getAllEvents {
    NSMutableArray *allEvents = [[NSMutableArray alloc] init];
    for(id key in _events) {
        NSArray *category = [_events objectForKey:key];
        for(int i = 0; i < category.count; ++i) {
            ListEvent *event = [category objectAtIndex:i];
            [allEvents addObject:event];
        }
    }
    
    return allEvents;
}

- (void)incrementKey {
    if([self isDisplayingAllEvents]) _currentKey = 0;
    else if([_currentKey isEqualToNumber:@8]) _currentKey = @0;
    else {
        NSInteger temp = _currentKey.integerValue;
        ++temp;
        _currentKey = [NSNumber numberWithInteger:temp];
    }
    //NSLog(@"events: %@ \ncurrentKey: %@",_events, _currentKey);
    if([[_events objectForKey:_currentKey] count] == 0) [self incrementKey];
}

- (void)decrementKey {
    if([self isDisplayingAllEvents]) _currentKey = @8;
    else if([_currentKey isEqualToNumber:@0]) _currentKey = @8;
    else {
        NSInteger temp = _currentKey.integerValue;
        --temp;
        _currentKey = [NSNumber numberWithInteger:temp];
    }
    if([[_events objectForKey:_currentKey] count] == 0) [self decrementKey];
}

- (NSNumber *)currentKey {
    if([self isDisplayingAllEvents]) return @99;
    if(![[_events objectForKey:_currentKey] count]) [self incrementKey];
    return _currentKey;
}

- (void)setCurrentKey:(NSNumber *)key {
    _currentKey = key;
}

- (int)numberOfEventsForCurrentKey {
    NSLog(@"current key: %@",_currentKey);
    if([self isDisplayingAllEvents]) {
        NSInteger totalNumberOfEvents = 0;
        for(NSNumber *key in _events) {
            NSArray *array = [_events objectForKey:key];
            totalNumberOfEvents += array.count;
        }
        return totalNumberOfEvents;
    }
    return [[_events objectForKey:_currentKey] count];
}

- (NSMutableArray *)eventsForCurrentKey {
    return [_events objectForKey:_currentKey];
}

- (BOOL)isDisplayingAllEvents {
    return [_currentKey isEqualToNumber:@99];
}

- (void)displayAllEvents {
    _currentKey = @99;
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
    
}

@end
