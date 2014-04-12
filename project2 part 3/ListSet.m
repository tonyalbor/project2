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

#define kEncodeKeyEvents     @"kEncodeKeyEvents"
#define kEncodeKeyCompleted  @"kEncodeKeyCompleted"
#define kEncodeKeyDeleted    @"kEncodeKeyDeleted"

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.events forKey:kEncodeKeyEvents];
    [aCoder encodeObject:self.completed forKey:kEncodeKeyCompleted];
    [aCoder encodeObject:self.deleted forKey:kEncodeKeyDeleted];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if ((self = [super init])) {
        self.events = [aDecoder decodeObjectForKey:kEncodeKeyEvents];
        self.completed = [aDecoder decodeObjectForKey:kEncodeKeyCompleted];
        self.deleted = [aDecoder decodeObjectForKey:kEncodeKeyDeleted];
    }
    
    return self;
}

- (NSString *)fileName {
    
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
    
}

- (void)incrementKey {
    
}

- (void)decrementKey {
    
}

- (int)numberOfEventsForCurrentKey {
    
}

- (NSMutableArray *)eventsForCurrentKey {
    
}

#pragma mark All Events

- (NSMutableArray *)getAllEvents {
    
}

- (void)displayAllEvents {
    
}

- (BOOL)isDisplayingAllEvents {
    
}

#pragma mark Helper Functions

- (void)organizeEvents {
    
}

- (void)addEvent:(ListEvent *)event toList:(NSMutableDictionary *)list {
    
}

@end
