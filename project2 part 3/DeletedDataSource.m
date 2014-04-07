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

- (void)deleteEvent:(ListEvent *)eventToBeDeleted {
    [super addEvent:eventToBeDeleted];
}

- (void)organizeEvents {
    
}

@end
