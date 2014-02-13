//
//  CompletedDataSource.m
//  project2 part 3
//
//  Created by Tony Albor on 2/10/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import "CompletedDataSource.h"
#import "ListEvent.h"

@implementation CompletedDataSource

@synthesize events;
@synthesize currentKey;

static CompletedDataSource *_sharedDataSource = nil;

+ (CompletedDataSource *)sharedDataSource {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataSource = [[CompletedDataSource alloc] init];
        _sharedDataSource.events = [[NSMapTable alloc] init];
        _sharedDataSource.currentKey = @0;
        // further initialization
    });
    
    return _sharedDataSource;
}

- (int)numberOfEventsForCurrentKey {
    return [[events objectForKey:currentKey] count];
}

- (void)completeEvent:(ListEvent *)event {
    // make sure there is a key set
    if(!event.categoryID) currentKey = @0;
    else currentKey = event.categoryID;
    
    // initialize array if nil
    if(![events objectForKey:currentKey]) {
        [events setObject:[NSMutableArray new] forKey:currentKey];
    }
    
    // add event to completed events
    [[events objectForKey:currentKey] addObject:event];
}

- (BOOL)isDisplayingAllEvents {
    return [currentKey isEqualToNumber:@99];
}

- (NSMutableArray *)getAllEvents {
    NSMutableArray *allEvents = [[NSMutableArray alloc] init];
    for(id key in events) {
        NSArray *category = [events objectForKey:key];
        for(ListEvent *event in category) {
            [allEvents addObject:event];
        }
    }
    
    return allEvents;
}

- (void)incrementKey {
    if([self isDisplayingAllEvents]) currentKey = @0;
    else if([currentKey isEqualToNumber:@8]) currentKey = @0;
    else {
        NSInteger temp = currentKey.integerValue;
        ++temp;
        currentKey = [NSNumber numberWithInteger:temp];
    }
    if([[events objectForKey:currentKey] count] == 0) [self incrementKey];
}

- (void)decrementKey {
    
}

- (NSNumber *)currentKey {
    if(![[events objectForKey:currentKey] count]) [self incrementKey];
    return currentKey;
}

@end
