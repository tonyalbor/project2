//
//  MemoryDataSource.m
//  project2 part 3
//
//  Created by Tony Albor on 2/13/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import "MemoryDataSource.h"

@implementation MemoryDataSource

static MemoryDataSource *_sharedDataSource = nil;

+ (MemoryDataSource *)sharedDataSource {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataSource = [[MemoryDataSource alloc] init];
    });
    return _sharedDataSource;
}

- (NSString *)getPathForFile:(NSString *)file {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    return [documentsDirectory stringByAppendingPathComponent:file];
}

- (void)saveDataWithDictionary:(NSDictionary *)dictionary toFile:(NSString *)file {
    [NSKeyedArchiver archiveRootObject:dictionary toFile:[self getPathForFile:file]];
}

- (NSDictionary *)readDataFromFile:(NSString *)file {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self getPathForFile:file]];
}

@end
