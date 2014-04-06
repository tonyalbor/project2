//
//  EventDataSource.h
//  project2 part 3
//
//  Created by Tony Albor on 4/5/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ListEvent;

@interface EventDataSource : NSObject

- (NSMutableDictionary *)mapToDictionary:(NSMapTable *)map;

@end
