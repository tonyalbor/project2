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
        _sharedDataSource.events = [[NSMapTable alloc] init];
        // further initialization
    });
    
    return _sharedDataSource;
}

- (void)completeEvent:(ListEvent *)event {
    // make sure there is a key set
    if(!currentKey) currentKey = @0;
    
    // initialize array if nil
    if(![events objectForKey:currentKey]) {
        [events setObject:[NSMutableArray new] forKey:currentKey];
    }
    
    // add event to completed events
    [[events objectForKey:currentKey] addObject:event];
}

@end
