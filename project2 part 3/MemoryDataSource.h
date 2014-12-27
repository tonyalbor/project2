//
//  MemoryDataSource.h
//  project2 part 3
//
//  Created by Tony Albor on 2/13/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemoryDataSource : NSObject

+ (void)_load;
+ (void)save; // TODO :: maybe add a save method to a listevent
+ (void)clear;

@end
