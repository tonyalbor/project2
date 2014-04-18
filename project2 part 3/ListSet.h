//
//  ListSet.h
//  project2 part 3
//
//  Created by Tony Albor on 4/10/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import <Foundation/Foundation.h>

#define EVENTS_DELETED @0
#define EVENTS_DUE @1
#define EVENTS_COMPLETED @2

@class ListEvent;
@class List;

@interface ListSet : NSObject <NSCoding> {
    NSNumber *_currentListVar;
}

// dictionaries for where the events are stored
@property (strong, nonatomic) List *due;
@property (strong, nonatomic) List *completed;
@property (strong, nonatomic) List *deleted;

// title used to name the list set
@property (strong, nonatomic) NSString *title;

// used as key for data source dictionary
@property (strong, nonatomic) NSNumber *dataSourceKey;

// used to keep track of the current list
- (void)setCurrentList:(NSNumber *)list;
- (List *)currentList;
- (NSNumber *)_currentList;

// returns the filename to read from and write to
- (NSString *)fileName;

// manage events
- (void)completeEvent:(ListEvent *)event;
- (void)deleteEvent:(ListEvent *)event;

// checks for current list
- (BOOL)isInDue;
- (BOOL)isInCompleted;
- (BOOL)isInDeleted;

@end
