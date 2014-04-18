//
//  List.m
//  project2 part 3
//
//  Created by Tony Albor on 4/15/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import "List.h"
#import "ListEvent.h"

#define kEncodeKeyEvents @"kEncodeKeyEvents"

@implementation List

- (id)init {
    if(!self) {
        self.events = [[NSMutableDictionary alloc] init];
        self.currentCategory = @0;
        self.recentlyAddedEvent = nil;
    }
    return self;
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_events forKey:kEncodeKeyEvents];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        _events = [aDecoder decodeObjectForKey:kEncodeKeyEvents];
    }
    return self;
}

#pragma mark Manage Events

- (void)addEvent:(ListEvent *)event {
    if(!_events) _events = [[NSMutableDictionary alloc] init];
    
    if(!event.categoryID) _currentCategory = @0;
    else _currentCategory = event.categoryID;
    
    if(![_events objectForKey:_currentCategory]) {
        [_events setObject:[NSMutableArray new] forKey:_currentCategory];
    }
    
    [[_events objectForKey:_currentCategory] addObject:event];
    
    _recentlyAddedEvent = event;
}

- (void)removeEvent:(ListEvent *)event {
    for(id key in _events) {
        [[_events objectForKey:key] removeObject:event];
    }
}

#pragma mark Current Category

- (void)incrementCategory {
    if([self isDisplayingAllEvents]) _currentCategory = @0;
    else if([_currentCategory isEqualToNumber:@8]) _currentCategory = @0;
    else {
        NSInteger temp = _currentCategory.integerValue;
        ++temp;
        _currentCategory = [NSNumber numberWithInteger:temp];
    }
    if(![_events objectForKey:_currentCategory]) [self incrementCategory];
}

- (void)decrementCategory {
    if([self isDisplayingAllEvents]) _currentCategory = @8;
    else if([_currentCategory isEqualToNumber:@0]) _currentCategory = @8;
    else {
        NSInteger temp = _currentCategory.integerValue;
        --temp;
        _currentCategory = [NSNumber numberWithInteger:temp];
    }
    if(![_events objectForKey:_currentCategory]) [self decrementCategory];
}

- (int)numberOfEventsForCurrentCategory {
    if([self isDisplayingAllEvents]) {
        int totalNumberOfEvents = 0;
        for(id key in _events) {
            NSArray *array = [_events objectForKey:key];
            totalNumberOfEvents += array.count;
        }
        return totalNumberOfEvents;
    }
    return (int)[[_events objectForKey:_currentCategory] count];
}

- (NSMutableArray *)eventsForCurrentCategory {
    return [_events objectForKey:_currentCategory];
}

#pragma mark All Events

- (void)displayAllEvents {
    _currentCategory = @99;
}

- (BOOL)isDisplayingAllEvents {
    return [_currentCategory isEqualToNumber:@99];
}

- (NSMutableArray *)getAllEvents {
    NSMutableArray *allEvents = [[NSMutableArray alloc] init];
    for(id key in _events) {
        NSArray *category = [_events objectForKey:key];
        for(ListEvent *event in category) {
            if(event != _recentlyAddedEvent)
                [allEvents addObject:event];
        }
    }
    if(_recentlyAddedEvent) [allEvents addObject:_recentlyAddedEvent];
    return allEvents;
}

- (int)numberOfEvents {
    int total = 0;
    for(id key in _events) {
        NSArray *category = [_events objectForKey:key];
        for(id event in category) {
            if(event) ++total;
        }
    }
    return total;
}

/*
 *   While events are added in, they might not be placed into the appropriate
 *   key so that the event can show up on screen. Otherwise the event might not
 *   show up if it is placed into a key that isn't currently being displayed.
 *
 *   This method is called once there needs to be an update to the UI, such as
 *   switching categories, so that the events can show up for the right key.
 */
- (void)organizeEvents {
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:_events];
    [_events removeAllObjects];
    
    for(id key in temp) {
        NSArray *category = [temp objectForKey:key];
        for(ListEvent *event in category) {
            if(![_events objectForKey:event.categoryID]) {
                [_events setObject:[[NSMutableArray alloc] init] forKey:event.categoryID];
            }
            [[_events objectForKey:event.categoryID] addObject:event];
        }
    }
}

@end
