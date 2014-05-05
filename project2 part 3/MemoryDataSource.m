//
//  MemoryDataSource.m
//  project2 part 3
//
//  Created by Tony Albor on 2/13/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import "MemoryDataSource.h"
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

+ (void)load {
    NSLog(@"is this the first thing to get called?");
    ListSetDataSource *datasource = [ListSetDataSource sharedDataSource];
    [datasource setSets:[[NSMutableDictionary alloc] init]];
 
    NSFileManager *fileManager = [NSFileManager defaultManager];
 
    if(![self fileExistsAt:@0]) {
        NSLog(@"no files exist");
        [datasource addSet:[[ListSet alloc] init]];
        [datasource setCurrentKey:@0];
        return;
    }
    // TODO :: all saving stuff right now doesnt work
    // once i get that done, it should be completely refactored, and ready to implement new features
    NSLog(@"files do exist");
 
    for(int key = 0; [fileManager fileExistsAtPath:[self getPathForFile:[NSString stringWithFormat:@"%@.txt",@(key)]]]; ++key) {
        // set datasource sets
        [datasource addSet:(ListSet *)[self readDataFromFile:[NSString stringWithFormat:@"%@.txt",@(key)]]];
        //NSLog(@"sets: %@",[datasource sets]);
 
//        ListSet *set = [[datasource sets] objectForKey:@(key)];
        //NSLog(@"12345%@",set.currentList.events);
 
  //      NSMutableDictionary *d = [[[[ListSetDataSource sharedDataSource] listSetForCurrentKey] currentList] events];
 
        //NSLog(@"%@",d);
        // current key will be set via user default, app delegate when closing app
    }
}

+ (void)save {
    NSMutableDictionary *sets = [[ListSetDataSource sharedDataSource] sets];
    for(id key in sets) {
        NSLog(@"about to save for key: %@",key);
        //NSString *filename = [NSString stringWithFormat:@"Untitled%@.txt",key];
        //NSString *filename = [[[ListSetDataSource sharedDataSource] listSetForCurrentKey] fileName];
        NSString *filename = [NSString stringWithFormat:@"%@.txt",key];
        NSLog(@"filename to save: %@",filename);
        ListSet *setToWrite = (ListSet *)[sets objectForKey:key];
        NSLog(@"datasource to save: %@",setToWrite.dataSourceKey);
        [self writeData:(ListSet *)[sets objectForKey:key] toFile:filename];
    }
}

+ (void)clear {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for(int key = 0; [self fileExistsAt:@(key)]; ++key) {
        NSError __autoreleasing *error;
        if([fileManager removeItemAtPath:[self getPathForFile:[NSString stringWithFormat:@"%@.txt",@(key)]] error:&error]) {
            NSLog(@"deleted file - %@.txt",@(key));
        } else NSLog(@"error: %@",error);
    }
}

#pragma mark Helper Functions

+ (BOOL)fileExistsAt:(NSNumber *)key {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:[self getPathForFile:[NSString stringWithFormat:@"%@.txt",key]]];
}

@end