//
//  MemoryDataSource.m
//  project2 part 3
//
//  Created by Tony Albor on 2/13/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import "MemoryDataSource.h"
#import "ListEventDataSource.h"
#import "CompletedDataSource.h"
#import "DeletedDataSource.h"
#import "ListSetDataSource.h"
#import "ListSet.h"

@implementation MemoryDataSource

#pragma mark I/O

+ (NSString *)getPathForFile:(NSString *)file {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    return [documentsDirectory stringByAppendingPathComponent:file];
}

+ (void)writeData:(id)data toFile:(NSString *)file {
    [NSKeyedArchiver archiveRootObject:data toFile:[self getPathForFile:file]];
}

+ (id)readDataFromFile:(NSString *)file {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self getPathForFile:file]];
}

#pragma mark ListSet

+ (void)load {
    id datasource = [ListSetDataSource sharedDataSource];
    [datasource setSets:[[NSMutableDictionary alloc] init]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for(int key = 0; [fileManager fileExistsAtPath:[self getPathForFile:[NSString stringWithFormat:@"%@.txt",@(key)]]]; ++key) {
        // set datasource sets
        [[datasource sets] setObject:(ListSet *)[self readDataFromFile:[NSString stringWithFormat:@"%@.txt",@(key)]] forKey:@(key)];
        
        // current key will be set via user default, app delegate when closing app
    }
}

+ (void)save {
    NSMutableDictionary *sets = [[ListSetDataSource sharedDataSource] sets];
    for(id key in sets) {
        [self writeData:(ListSet *)[sets objectForKey:key] toFile:[NSString stringWithFormat:@"%@.txt",key]];
    }
}

+ (void)clear {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for(id key in [[ListEventDataSource sharedDataSource] sets]) {
        [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@.txt",key] error:nil];
    }
}

@end
