//
//  ListEventDataSource.h
//  project2 part 3
//
//  Created by Tony Albor on 9/8/13.
//  Copyright (c) 2013 tonyalbor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventDataSource.h"

@class ListEvent;

@interface ListEventDataSource : EventDataSource

@property (strong, nonatomic) ListEvent *recentlyAddedEvent;

- (void)removeEvent:(ListEvent *)eventToBeRemoved;
- (void)removeEventAtIndexPath:(NSIndexPath *)indexPath;
- (ListEvent *)eventForIndexPath:(NSIndexPath *)indexPath;

- (int)numberOfEventsForCurrentKey;
- (NSMutableArray *)eventsForCurrentKey;

@end
