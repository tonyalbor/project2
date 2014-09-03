//
//  List.m
//  project2 part 3
//
//  Created by Tony Albor on 4/15/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import "List.h"
#import "ListEvent.h"
#import "CustomCellColor.h"

#define kEncodeKeyEvents @"kEncodeKeyEvents"

@implementation List

- (id)init {
    self.events = [[NSMutableDictionary alloc] init];
    self.currentCategory = @0;
    [self.events setObject:[NSMutableArray new] forKey:self.currentCategory];
    self.recentlyAddedEvent = nil;
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
    
    // if all events are shown or current category is nil, set event id to 0
    // else set it to current category
    if(!_currentCategory || [self isDisplayingAllEvents]) event.categoryID = @0;
    else event.categoryID = _currentCategory;
    
    // sort id is the index of the event, based on category
    // TODO :: i need to change this every time the cell color changes
    // and when an actual reordering occurs
    // once there is a change on screen (e.g. switchCategory, nextListSet),
    // i should go through and update all the sortIds
    // i should probably set some kind of boolean value to determine
    // if i need to make those updates (updateSortIds)
    event.sortId = @([self numberOfEventsForCurrentCategory]-1);
    
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
    else if([_currentCategory isEqualToNumber:[CustomCellColor numberOfCustomColors]]) _currentCategory = @0;
    else {
        NSInteger temp = _currentCategory.integerValue;
        ++temp;
        _currentCategory = [NSNumber numberWithInteger:temp];
    }
    if(![_events objectForKey:_currentCategory]) [self incrementCategory];
}

- (void)decrementCategory {
    if([self isDisplayingAllEvents]) _currentCategory = [CustomCellColor numberOfCustomColors];
    else if([_currentCategory isEqualToNumber:@0]) _currentCategory = [CustomCellColor numberOfCustomColors];
    else {
        NSInteger temp = _currentCategory.integerValue;
        --temp;
        _currentCategory = [NSNumber numberWithInteger:temp];
    }
    if(![_events objectForKey:_currentCategory]) [self decrementCategory];
}

- (int)numberOfEventsForCurrentCategory {
    if([self isDisplayingAllEvents]) {
        return [self numberOfEvents];
    }
    return (int)[[_events objectForKey:_currentCategory] count];
}

// TODO :: go through and return events in order by sort id
- (NSMutableArray *)eventsForCurrentCategory {
    if([self isDisplayingAllEvents]) {
        return [self getAllEvents];
    }
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

- (BOOL)isEmpty {
    return (!_events || _events.count == 0);
}

// TODO :: think about when sorting by date
// i can probably just have another method that sorts by date
- (void)updateSortIds {
    for(id key in _events) {
        NSArray *category = [_events objectForKey:key];
        for(int i = 0; i < category.count; ++i) {
            ListEvent *event = (ListEvent *)[category objectAtIndex:i];
            event.sortId = @(i);
        }
    }
}

@end
