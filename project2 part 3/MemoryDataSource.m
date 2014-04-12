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

+ (NSString *)getPathForFile:(NSString *)file {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    return [documentsDirectory stringByAppendingPathComponent:file];
}

+ (void)writeDataWithDictionary:(NSDictionary *)dictionary toFile:(NSString *)file {
    [NSKeyedArchiver archiveRootObject:dictionary toFile:[self getPathForFile:file]];
}

+ (NSDictionary *)readDataFromFile:(NSString *)file {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self getPathForFile:file]];
}

+ (void)loadListSetData {
    id datasource = [ListSetDataSource sharedDataSource];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:[self getPathForFile:@"list-sets.txt"]]) {
        // file exists, do some cool stuff
        [datasource setSets:(NSMutableDictionary *)[self readDataFromFile:@"list-sets.txt"]];
    } else {
        [datasource setSets:[[NSMutableDictionary alloc] init]];
    }
}

+ (void)saveListSetData {
    NSDictionary *write = [ListSetDataSource sharedDataSource].sets;
    NSString *file = @"list-sets.txt";
    [self writeDataWithDictionary:write toFile:file];
}

+ (void)loadEventsForDataSource:(id)sharedDataSource {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:[self getPathForFile:[sharedDataSource fileName]]]) {
        [sharedDataSource setCurrentKey:@99];
        [sharedDataSource setEvents:(NSMapTable *)[self readDataFromFile:[sharedDataSource fileName]]];
    } else {
        [sharedDataSource setCurrentKey:@0];
        [sharedDataSource setEvents:[[NSMapTable alloc] init]];
    }
}

+ (void)saveEventsForDataSource:(id)sharedDataSource {
    NSDictionary *write = [sharedDataSource mapToDictionary:[sharedDataSource events]];
    NSString *file = [sharedDataSource fileName];
    [self writeDataWithDictionary:write toFile:file];
}

+ (void)loadAllEvents {
    [self loadListSetData];
    id datasource = [ListSetDataSource sharedDataSource];
    for(id key in [datasource sets]) {
        ListSet *set = [[datasource sets] objectForKey:key];
        [self loadEventsForDataSource:set.due];
        [self loadEventsForDataSource:set.completed];
        [self loadEventsForDataSource:set.deleted];
    }
}

+ (void)saveAllEvents {
    id datasource = [ListSetDataSource sharedDataSource];
    for(id key in [datasource sets]) {
        ListSet *set = [[datasource sets] objectForKey:key];
        [self saveEventsForDataSource:set.due];
        [self saveEventsForDataSource:set.completed];
        [self saveEventsForDataSource:set.deleted];
    }
}

+ (void)saveAllEventsForListSet:(ListSet *)set {
    [self saveEventsForDataSource:set.due];
    [self saveEventsForDataSource:set.completed];
    [self saveEventsForDataSource:set.deleted];
}

+ (void)deleteFile:(NSString *)file {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:file]) [fileManager removeItemAtPath:file error:nil];
}

+ (void)clearEverything {
    NSString *list = [self getPathForFile:[[ListEventDataSource sharedDataSource] fileName]];
    NSString *completed = [self getPathForFile:[[CompletedDataSource sharedDataSource] fileName]];
    NSString *deleted = [self getPathForFile:[[DeletedDataSource sharedDataSource] fileName]];
    
    [self deleteFile:list];
    [self deleteFile:completed];
    [self deleteFile:deleted];
}

@end
