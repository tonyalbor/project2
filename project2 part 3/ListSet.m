//
//  ListSet.m
//  project2 part 3
//
//  Created by Tony Albor on 4/10/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import "ListSet.h"
#import "ListEvent.h"
#import "List.h"

#define kEncodeKeyDue         @"kEncodeKeyDue"
#define kEncodeKeyCompleted   @"kEncodeKeyCompleted"
#define kEncodeKeyDeleted     @"kEncodeKeyDeleted"
#define kEncodeKeyCurrentList  @"kEncodeKeyCurrentList"
#define kEncodeKeyTitle       @"kEncodeKeyTitle"

@implementation ListSet

- (id)init {
    self.due = [[List alloc] init];
    self.completed = [[List alloc] init];
    self.deleted = [[List alloc] init];
    _currentListVar = EVENTS_DUE;
    
    // TODO :: figure out when i can set this
//    if(self.dataSourceKey == nil) //self.dataSourceKey = @99;
    self.title = [NSString stringWithFormat:@"Untitled%@",self.dataSourceKey];
    
    return self;
}

#pragma mark Current List

- (void)setCurrentList:(NSNumber *)list {
    _currentListVar = list;
}

- (List *)currentList {
    switch(_currentListVar.intValue) {
        case 0: return self.deleted;
        case 1: return self.due;
        case 2: return self.completed;
        default: return nil;
    }
}

- (NSNumber *)_currentList {
    if(_currentListVar == nil) _currentListVar = @0;
    return _currentListVar;
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeObject:self.due forKey:kEncodeKeyDue];
    [aCoder encodeObject:self.completed forKey:kEncodeKeyCompleted];
    [aCoder encodeObject:self.deleted forKey:kEncodeKeyDeleted];
    [aCoder encodeObject:_currentListVar forKey:kEncodeKeyCurrentList];
    [aCoder encodeObject:self.title forKey:kEncodeKeyTitle];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if ((self = [super init])) {
        self.due = [aDecoder decodeObjectForKey:kEncodeKeyDue];
        self.completed = [aDecoder decodeObjectForKey:kEncodeKeyCompleted];
        self.deleted = [aDecoder decodeObjectForKey:kEncodeKeyDeleted];
        self.currentList = [aDecoder decodeObjectForKey:kEncodeKeyCurrentList];
        self.title = [aDecoder decodeObjectForKey:kEncodeKeyTitle];
    }
    
    return self;
}

#pragma mark File

- (NSString *)fileName {
    return [NSString stringWithFormat:@"%@.txt",self.dataSourceKey];
}

#pragma mark Manage Events

- (void)dueEvent:(ListEvent *)event {
    [self addEvent:event toList:_due];
}

- (void)completeEvent:(ListEvent *)event {
    [self addEvent:event toList:_completed];
}

- (void)deleteEvent:(ListEvent *)event {
    [self addEvent:event toList:_deleted];
}

#pragma mark Helper Functions

- (void)addEvent:(ListEvent *)event toList:(List *)list {
    // set events if nil
    if(![list events]) {
        list.events = [[NSMutableDictionary alloc] init];
        
    }
    // set array if nil
    if(![list.events objectForKey:event.categoryID]) {
        [list.events setObject:[NSMutableArray new] forKey:event.categoryID];
    }
    
    // add event for event.categoryID
    [[list.events objectForKey:event.categoryID] addObject:event];
}

- (void)print {
    // implement a pretty print for logging
    
    
}

#pragma mark Check For Current List

- (BOOL)isInDue {
    return [_currentListVar isEqualToNumber:EVENTS_DUE];
}

- (BOOL)isInDeleted {
    return [_currentListVar isEqualToNumber:EVENTS_DELETED];
}

- (BOOL)isInCompleted {
    return [_currentListVar isEqualToNumber:EVENTS_COMPLETED];
}

@end
