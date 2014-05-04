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
