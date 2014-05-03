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
#import "List.h"

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
/*
+ (void)load {
    return;
    NSLog(@"wow");
    id datasource = [ListSetDataSource sharedDataSource];
    [datasource setSets:[[NSMutableDictionary alloc] init]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![self filesExist]) {
        NSLog(@"no files exist");
        [datasource addSet:[[ListSet alloc] init] forKey:@0];
        return;
    }
    // TODO :: all saving stuff right now doesnt work
    // once i get that done, it should be completely refactored, and ready to implement new features
    NSLog(@"files do exist");
    
    for(int key = 0; [fileManager fileExistsAtPath:[self getPathForFile:[NSString stringWithFormat:@"%@.txt",@(key)]]]; ++key) {
        // set datasource sets
        [datasource addSet:(ListSet *)[self readDataFromFile:[NSString stringWithFormat:@"%@.txt",@(key)]] forKey:@(key)];
        //NSLog(@"sets: %@",[datasource sets]);
        
        ListSet *set = [[datasource sets] objectForKey:@0];
        //NSLog(@"12345%@",set.currentList.events);

        NSMutableDictionary *d = [[[[ListSetDataSource sharedDataSource] listSetForCurrentKey] currentList] events];
        
        //NSLog(@"%@",d);
        // current key will be set via user default, app delegate when closing app
    }
}*/

+ (void)save {
    NSMutableDictionary *sets = [[ListSetDataSource sharedDataSource] sets];
    for(id key in sets) {
        //NSString *filename = [NSString stringWithFormat:@"Untitled%@.txt",key];
        NSString *filename = [[[ListSetDataSource sharedDataSource] listSetForCurrentKey] fileName];
        [self writeData:(ListSet *)[sets objectForKey:key] toFile:filename];
    }
}

+ (void)clear {
    id datasource = [ListSetDataSource sharedDataSource];
    NSFileManager *fileManager = [NSFileManager defaultManager];
//    for(id key in [datasource sets]) {
    for(int i = 0; i < [[datasource sets] allKeys].count; ++i) {
        NSNumber *key;
        NSLog(@"key: %@",key);
        [datasource removeSet:[datasource listSetForCurrentKey]];
        NSString *filename = [NSString stringWithFormat:@"%@.txt",key];
        if([fileManager fileExistsAtPath:[self getPathForFile:filename] isDirectory:NO]) {
            NSLog(@"exists");
            NSError __autoreleasing *error;
            if([fileManager removeItemAtPath:[self getPathForFile:filename] error:&error])
                NSLog(@"deleted");
            else NSLog(@"error: %@",error);
    
        } else NSLog(@"does not exist");
    }
}

#pragma mark Helper Functions

+ (BOOL)filesExist {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:[self getPathForFile:@"0.txt"]];
}

@end
