//
//  DeletedDataSource.m
//  project2 part 3
//
//  Created by Tony Albor on 2/10/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import "DeletedDataSource.h"
#import "ListEvent.h"
#import "MemoryDataSource.h"

#define DeletedDataSourceFile @"deleted.txt"

@implementation DeletedDataSource

@synthesize events;
@synthesize currentKey;

static DeletedDataSource *_sharedDataSource = nil;

+ (DeletedDataSource *)sharedDataSource {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataSource = [[DeletedDataSource alloc] init];
        // further initialization
    });
    
    return _sharedDataSource;
}

- (NSString *)fileName {
    return DeletedDataSourceFile;
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

- (void)displayAllEvents {
    currentKey = @99;
}

- (NSArray *)eventsForCurrentKey {
    return [events objectForKey:currentKey];
}

- (NSNumber *)currentKey {
    if([self isDisplayingAllEvents]) return @99;
    if(![[events objectForKey:currentKey] count]) [self incrementCurrentKey];
    return currentKey;
}

- (void)deleteEvent:(ListEvent *)eventToBeDeleted {
    // set current key if nil
    if(!eventToBeDeleted.categoryID) currentKey = @0;
    else currentKey = eventToBeDeleted.categoryID;
    
    // init some stuff
    if(![events objectForKey:currentKey]) {
        [events setObject:[NSMutableArray new] forKey:currentKey];
    }
    
    // delete that mofo
    [[events objectForKey:currentKey] addObject:eventToBeDeleted];
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

- (void)organizeEvents {
    
}

@end
