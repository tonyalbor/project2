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

@synthesize events;
@synthesize currentKey;

+ (id)sharedDataSource {
    return nil;
}

- (NSString *)fileName {
    return nil;
}

- (void)addEvent:(ListEvent *)event {
    // set events if nil
    if(!events) events = [[NSMapTable alloc] init];
    
    // make sure there is a key set
    if(!event.categoryID) currentKey = @0;
    else currentKey = event.categoryID;
    
    // initialize array if nil
    if(![events objectForKey:currentKey]) {
        [events setObject:[NSMutableArray new] forKey:currentKey];
    }
    
    // add event to data source
    [[events objectForKey:currentKey] addObject:event];
}

- (ListEvent *)eventForSortId:(NSInteger)sort {
    BOOL allEventsShown = [self isDisplayingAllEvents];
    
    NSArray *eventsDisplayed = allEventsShown ? [self getAllEvents] : [events objectForKey:currentKey];
    for(ListEvent *event in eventsDisplayed) {
        if([event.sortId isEqualToNumber:@(sort)]) return event;
    }
    
    return nil;
}

- (NSMutableArray *)getAllEvents {
    NSMutableArray *allEvents = [[NSMutableArray alloc] init];
    for(id key in events) {
        NSArray *category = [events objectForKey:key];
        for(int i = 0; i < category.count; ++i) {
            ListEvent *event = [category objectAtIndex:i];
            [allEvents addObject:event];
        }
    }
    
    return allEvents;
}

- (void)incrementKey {
    if([self isDisplayingAllEvents]) currentKey = @0;
    else if([currentKey isEqualToNumber:@8]) currentKey = @0;
    else {
        NSInteger temp = currentKey.integerValue;
        ++temp;
        currentKey = [NSNumber numberWithInteger:temp];
    }
    if([[events objectForKey:currentKey] count] == 0) [self incrementKey];
}

- (void)decrementKey {
    if([self isDisplayingAllEvents]) currentKey = @8;
    else if([currentKey isEqualToNumber:@0]) currentKey = @8;
    else {
        NSInteger temp = currentKey.integerValue;
        --temp;
        currentKey = [NSNumber numberWithInteger:temp];
    }
    if([[events objectForKey:currentKey] count] == 0) [self decrementKey];
}

- (NSNumber *)currentKey {
    if([self isDisplayingAllEvents]) return @99;
    if(![[events objectForKey:currentKey] count]) [self incrementKey];
    return currentKey;
}

- (int)numberOfEventsForCurrentKey {
    NSLog(@"current key: %@",currentKey);
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

- (NSMutableArray *)eventsForCurrentKey {
    return [events objectForKey:currentKey];
}

- (BOOL)isDisplayingAllEvents {
    return [currentKey isEqualToNumber:@99];
}

- (void)displayAllEvents {
    currentKey = @99;
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
