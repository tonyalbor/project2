//
//  ListSetDataSource.m
//  project2 part 3
//
//  Created by Tony Albor on 4/10/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import "ListSetDataSource.h"
#import "ListSet.h"

@implementation ListSetDataSource

static ListSetDataSource *_sharedDataSource = nil;

+ (ListSetDataSource *)sharedDataSource {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataSource = [[ListSetDataSource alloc] init];
    });
    return _sharedDataSource;
}

- (void)addSet:(ListSet *)set {
    if(!_sets) _sets = [[NSMutableDictionary alloc] init];
    [_sets setObject:set forKey:set.key];
}

- (void)removeSet:(ListSet *)set {
    if(_sets) [_sets removeObjectForKey:set.key];
}



@end
