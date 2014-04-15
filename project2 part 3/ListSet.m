//
//  ListSet.m
//  project2 part 3
//
//  Created by Tony Albor on 4/10/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import "ListSet.h"
#import "ListEvent.h"

@implementation ListSet

@synthesize recentlyAddedEvent;

#define kEncodeKeyEvents      @"kEncodeKeyEvents"
#define kEncodeKeyCompleted   @"kEncodeKeyCompleted"
#define kEncodeKeyDeleted     @"kEncodeKeyDeleted"
#define kEncodeKeyCurrentKey  @"kEncodeKeyCurrentKey"
#define kEncodeKeyTitle       @"kEncodeKeyTitle"

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.events forKey:kEncodeKeyEvents];
    [aCoder encodeObject:self.completed forKey:kEncodeKeyCompleted];
    [aCoder encodeObject:self.deleted forKey:kEncodeKeyDeleted];
    [aCoder encodeObject:self.currentKey forKey:kEncodeKeyCurrentKey];
    [aCoder encodeObject:self.title forKey:kEncodeKeyTitle];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if ((self = [super init])) {
        self.events = [aDecoder decodeObjectForKey:kEncodeKeyEvents];
        self.completed = [aDecoder decodeObjectForKey:kEncodeKeyCompleted];
        self.deleted = [aDecoder decodeObjectForKey:kEncodeKeyDeleted];
        self.currentKey = [aDecoder decodeObjectForKey:kEncodeKeyCurrentKey];
        self.title = [aDecoder decodeObjectForKey:kEncodeKeyTitle];
    }
    
    return self;
}

- (NSString *)fileName {
    return [NSString stringWithFormat:@"%@.txt",self.title];
}

#pragma mark Manage Events

- (void)addEvent:(ListEvent *)event {
    [self addEvent:event toList:_events];
    recentlyAddedEvent = event;
}

- (void)completeEvent:(ListEvent *)event {
    [self addEvent:event toList:_completed];
}

- (void)deleteEvent:(ListEvent *)event {
    [self addEvent:event toList:_deleted];
}

#pragma mark Current Key

- (NSNumber *)currentKey {
    if([self isDisplayingAllEvents]) return @99;
    if(![[_events objectForKey:_currentKey] count]) [self incrementKey];
    return _currentKey;
}

- (void)incrementKey {
    if([self isDisplayingAllEvents]) _currentKey = 0;
    else if([_currentKey isEqualToNumber:@8]) _currentKey = @0;
    else {
        NSInteger temp = _currentKey.integerValue;
        ++temp;
        _currentKey = [NSNumber numberWithInteger:temp];
    }
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

- (int)numberOfEventsForCurrentKey {
    if([self isDisplayingAllEvents]) {
        int totalNumberOfEvents = 0;
        for(NSNumber *key in _events) {
            NSArray *array = [_events objectForKey:key];
            totalNumberOfEvents += array.count;
        }
        return totalNumberOfEvents;
    }
    return (int)[[_events objectForKey:_currentKey] count];
}

- (NSMutableArray *)eventsForCurrentKey {
    return [_events objectForKey:_currentKey];
}

#pragma mark All Events

- (NSMutableArray *)getAllEventsForList:(NSMutableDictionary *)list {
    NSMutableArray *allEvents = [[NSMutableArray alloc] init];
    for(id key in list) {
        NSArray *category = [list objectForKey:key];
        /*for(int i = 0; i < category.count; ++i) {
            ListEvent *event = [category objectAtIndex:i];
            [allEvents addObject:event];
        }*/
        
        // keep this for now, i dont know why i didnt do it like this before,
        // but there might be a reason
        for(ListEvent *event in category) {
            [allEvents addObject:event];
        }
    }
    
    return allEvents;
}

- (void)displayAllEvents {
    _currentKey = @99;
}

- (BOOL)isDisplayingAllEvents {
    return [_currentKey isEqualToNumber:@99];
}

#pragma mark Helper Functions

- (void)organizeEvents {
    
}

- (void)addEvent:(ListEvent *)event toList:(NSMutableDictionary *)list {
    // set current key for event category id
    if(!event.categoryID) _currentKey = @0;
    else _currentKey = event.categoryID;
    
    // initialize array for current key if nil
    if(![list objectForKey:_currentKey]) {
        [list setObject:[NSMutableArray new] forKey:_currentKey];
    }
    
    // add event for current key
    [[list objectForKey:_currentKey] addObject:event];
}

@end
