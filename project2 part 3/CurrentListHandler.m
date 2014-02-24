//
//  CurrentListHandler.m
//  project2 part 3
//
//  Created by Tony Albor on 2/12/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import "CurrentListHandler.h"
#import "ListEventDataSource.h"
#import "CompletedDataSource.h"
#import "DeletedDataSource.h"

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

- (id)currentListDataSource {
    int list = currentList.intValue;
    
    switch(list) {
        case 0:
            return [DeletedDataSource sharedDataSource];
        case 1:
            return [ListEventDataSource sharedDataSource];
        case 2:
            return [CompletedDataSource sharedDataSource];
        default:
            // what
            return nil;
    }
    
    return nil;
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
