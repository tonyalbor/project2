//
//  CompletedDataSource.m
//  project2 part 3
//
//  Created by Tony Albor on 2/10/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import "CompletedDataSource.h"
#import "ListEvent.h"

#define CompletedDataSourceFile @"completed.txt"

@implementation CompletedDataSource

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

- (void)completeEvent:(ListEvent *)event {
    [super addEvent:event];
}

- (void)organizeEvents {
    
}

@end
