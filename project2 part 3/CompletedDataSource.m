//
//  CompletedDataSource.m
//  project2 part 3
//
//  Created by Tony Albor on 2/10/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import "CompletedDataSource.h"
#import "ListEvent.h"
#import "MemoryDataSource.h"

#define CompletedDataSourceFile @"completed.txt"

@implementation CompletedDataSource

@synthesize events;
@synthesize currentKey;

static CompletedDataSource *_sharedDataSource = nil;

+ (CompletedDataSource *)sharedDataSource {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataSource = [[CompletedDataSource alloc] init];
        // further initialization
    });
    
    return _sharedDataSource;
}

- (NSString *)fileName {
    return CompletedDataSourceFile;
}

- (int)numberOfEventsForCurrentKey {
    if([self isDisplayingAllEvents]) {
        NSInteger totalNumberOfEvents = 0;
        for(NSNumber *key in events) {
            NSArray *array = [events objectForKey:key];
            totalNumberOfEvents += array.count;
        }
        return totalNumberOfEvents;
    }
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

- (void)displayAllEvents {
    currentKey = @99;
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

- (void)incrementCurrentKey {
    if([self isDisplayingAllEvents]) currentKey = @0;
    else if([currentKey isEqualToNumber:@8]) currentKey = @0;
    else {
        NSInteger temp = currentKey.integerValue;
        ++temp;
        currentKey = [NSNumber numberWithInteger:temp];
    }
    if([[events objectForKey:currentKey] count] == 0) [self incrementCurrentKey];
}

- (void)decrementCurrentKey {
    if([self isDisplayingAllEvents]) currentKey = @8;
    else if([currentKey isEqualToNumber:@0]) currentKey = @8;
    else {
        NSInteger temp = currentKey.integerValue;
        --temp;
        currentKey = [NSNumber numberWithInteger:temp];
    }
    if([[events objectForKey:currentKey] count] == 0) [self decrementCurrentKey];
}

- (NSNumber *)currentKey {
    if([self isDisplayingAllEvents]) return @99;
    if(![[events objectForKey:currentKey] count]) [self incrementKey];
    return currentKey;
}

- (NSArray *)eventsForCurrentKey {
    return [events objectForKey:currentKey];
}

- (void)organizeEvents {
    
}

@end
