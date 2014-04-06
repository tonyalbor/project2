//
//  DeletedDataSource.h
//  project2 part 3
//
//  Created by Tony Albor on 2/10/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ListEvent;

@interface DeletedDataSource : NSObject

@property (strong, nonatomic) NSMapTable *events;

@property (strong, nonatomic) NSNumber *currentKey;

+ (DeletedDataSource *)sharedDataSource;

- (NSString *)fileName;

- (void)deleteEvent:(ListEvent *)eventToBeDeleted;

- (int)numberOfEventsForCurrentKey;

- (NSMutableArray *)getAllEvents;
- (BOOL)isDisplayingAllEvents;
- (void)incrementCurrentKey;
- (void)decrementCurrentKey;
- (NSArray *)eventsForCurrentKey;
- (void)displayAllEvents;

- (void)organizeEvents;

@end
