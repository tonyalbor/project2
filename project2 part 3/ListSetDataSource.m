//
//  ListSetDataSource.m
//  project2 part 3
//
//  Created by Tony Albor on 4/10/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import "ListSetDataSource.h"
#import "ListSet.h"
#import "List.h"
#import "ListEvent.h"

@implementation ListSetDataSource

static ListSetDataSource *_sharedDataSource = nil;

+ (ListSetDataSource *)sharedDataSource {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataSource = [[ListSetDataSource alloc] init];
        _sharedDataSource.sets = [[NSMutableDictionary alloc] init];
        _sharedDataSource.currentKey = @0;
        _sharedDataSource.recentlyAddedSet = @0;
    });
    return _sharedDataSource;
}

- (NSString *)prefixFileName {
    return [[_sets objectForKey:_currentKey] title];
}

- (void)addSet:(ListSet *)set {
    if(!_sets) _sets = [[NSMutableDictionary alloc] init];
    set.dataSourceKey = [self getNewKey];
    [_sets setObject:set forKey:set.dataSourceKey];
    _recentlyAddedSet = set.dataSourceKey;
}

- (void)removeSet:(ListSet *)set {
    for(int key = set.dataSourceKey.intValue; [_sets objectForKey:@(key)]; ++key) {
        if([_sets objectForKey:@(key+1)]) {
            // replace
            [_sets setObject:[_sets objectForKey:@(key+1)] forKey:@(key)];
        } else {
            // delete
            [_sets removeObjectForKey:@(key)];
        }
    }
}

- (id)currentKey {
    return _currentKey;
}

- (void)incrementKey {
    NSNumber *nextKey = @(_currentKey.intValue + 1);
    _currentKey = [_sets objectForKey:nextKey] ? nextKey : @0;
}

- (void)decrementKey {
    _currentKey = [_currentKey isEqualToNumber:@0] ? @(_sets.count-1) : @(_currentKey.intValue-1);
}

- (ListSet *)listSetForCurrentKey {
    return [_sets objectForKey:_currentKey];
}

- (NSArray *)getAllSets {
    NSMutableArray *setsArray = [[NSMutableArray alloc] init];
    for(id key in _sets) [setsArray addObject:[_sets objectForKey:key]];
    return setsArray;
}

- (NSInteger)numberOfSets {
    
    return [_sets count];
}

- (ListEvent *)eventAtIndex:(NSInteger)index {
    return [[[[self listSetForCurrentKey] currentList] eventsForCurrentCategory] objectAtIndex:index];
}

#pragma mark Private Methods

- (NSNumber *)getNewKey {
    return @(_sets.allKeys.count);
}

@end
