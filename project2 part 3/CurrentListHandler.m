//
//  CurrentListHandler.m
//  project2 part 3
//
//  Created by Tony Albor on 2/12/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import "CurrentListHandler.h"
#import "ListSet.h"

@implementation CurrentListHandler

@synthesize currentList;

static CurrentListHandler *_sharedDataSource = nil;

+ (CurrentListHandler *)sharedDataSource {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataSource = [[CurrentListHandler alloc] init];
        _sharedDataSource.currentList = @1;
    });
    
    return _sharedDataSource;
}

- (void)setCurrentList:(NSNumber *)list {
    currentList = list;
}

- (NSDictionary *)currentListForSet:(ListSet *)set {
    switch(currentList.intValue) {
        case 0: return [set deleted];
        case 1: return [set due];
        case 2: return [set completed];
        default: return nil;
    }
}

- (BOOL)isInEvents {
    return currentList.intValue == 1;
}

- (BOOL)isInCompleted {
    return currentList.intValue == 2;
}

- (BOOL)isInDeleted {
    return currentList.intValue == 0;
}

@end
