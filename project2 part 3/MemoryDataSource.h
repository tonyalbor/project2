//
//  MemoryDataSource.h
//  project2 part 3
//
//  Created by Tony Albor on 2/13/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemoryDataSource : NSObject

+ (MemoryDataSource *)sharedDataSource;

- (void)saveData;

@end
