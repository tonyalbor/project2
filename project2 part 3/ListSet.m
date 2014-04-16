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

#pragma mark Current List

- (void)setCurrentList:(NSNumber *)list {
    _currentList = list;
}

- (List *)currentList {
    switch(_currentList.intValue) {
        case 0: return self.deleted;
        case 1: return self.due;
        case 2: return self.completed;
        default: return nil;
    }
}

- (NSNumber *)_currentList {
    return _currentList;
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeObject:self.due forKey:kEncodeKeyDue];
    [aCoder encodeObject:self.completed forKey:kEncodeKeyCompleted];
    [aCoder encodeObject:self.deleted forKey:kEncodeKeyDeleted];
    //[aCoder encodeObject:self.currentList forKey:kEncodeKeyCurrentList];
    [aCoder encodeObject:self.title forKey:kEncodeKeyTitle];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if ((self = [super init])) {
        self.due = [aDecoder decodeObjectForKey:kEncodeKeyDue];
        self.completed = [aDecoder decodeObjectForKey:kEncodeKeyCompleted];
        self.deleted = [aDecoder decodeObjectForKey:kEncodeKeyDeleted];
        //self.currentList = [aDecoder decodeObjectForKey:kEncodeKeyCurrentList];
        self.title = [aDecoder decodeObjectForKey:kEncodeKeyTitle];
    }
    
    return self;
}

#pragma mark File

- (NSString *)fileName {
    return [NSString stringWithFormat:@"%@.txt",self.title];
}

#pragma mark Manage Events

- (void)completeEvent:(ListEvent *)event {
    [self addEvent:event toList:_completed];
}

- (void)deleteEvent:(ListEvent *)event {
    [self addEvent:event toList:_deleted];
}

#pragma mark Helper Functions

- (void)addEvent:(ListEvent *)event toList:(List *)list {
    // set array if nil
    if(![[list events] objectForKey:event.categoryID]) {
        [[list events] setObject:[NSMutableArray new] forKey:event.categoryID];
    }
    
    // add event for event.categoryID
    [[[list events] objectForKey:event.categoryID] addObject:event];
}

#pragma mark Check For Current List

- (BOOL)isInDue {
    return [_currentList isEqualToNumber:@1];
}

- (BOOL)isInDeleted {
    return [_currentList isEqualToNumber:@0];
}

- (BOOL)isInCompleted {
    return [_currentList isEqualToNumber:@2];
}

@end
