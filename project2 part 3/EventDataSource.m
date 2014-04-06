//
//  EventDataSource.m
//  project2 part 3
//
//  Created by Tony Albor on 4/5/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import "EventDataSource.h"
#import "ListEvent.h"

@implementation EventDataSource

- (NSMutableDictionary *)mapToDictionary:(NSMapTable *)map {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    for(NSNumber *key in map) {
        [dictionary setObject:[[NSMutableArray alloc] init] forKey:key];
        NSArray *array = [map objectForKey:key];
        ListEvent *event = [[ListEvent alloc] init];
        for(int i = 0; i < array.count; ++i) {
            event = [array objectAtIndex:i];
            [[dictionary objectForKey:key] addObject:event];
        }
    }
    return dictionary;
}

@end
