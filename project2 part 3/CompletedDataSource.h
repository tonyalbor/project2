//
//  CompletedDataSource.h
//  project2 part 3
//
//  Created by Tony Albor on 2/10/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventDataSource.h"

@class ListEvent;

@interface CompletedDataSource : EventDataSource

- (void)completeEvent:(ListEvent *)event;

@end
