//
//  DeletedDataSource.m
//  project2 part 3
//
//  Created by Tony Albor on 2/10/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import "DeletedDataSource.h"
#import "ListEvent.h"

@implementation DeletedDataSource

@synthesize events;
@synthesize currentKey;

static DeletedDataSource *_sharedDataSource = nil;

+ (DeletedDataSource *)sharedDataSource {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataSource.events = [[NSMapTable alloc] init];
        // further initialization
    });
    
    return _sharedDataSource;
}

- (void)deleteEvent:(ListEvent *)event {
    // set current key if nil
    if(!currentKey) currentKey = @0;
    
    // init some stuff
    if(![events objectForKey:currentKey]) {
        [events setObject:[NSMutableArray new] forKey:currentKey];
    }
    
    // delete that mofo
    [[events objectForKey:currentKey] addObject:event];
}

@end
