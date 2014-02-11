//
//  DeletedDataSource.h
//  project2 part 3
//
//  Created by Tony Albor on 2/10/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ListEvent;

@interface DeletedDataSource : NSObject

+ (DeletedDataSource *)sharedDataSource;

@property (strong, nonatomic) NSMapTable *events;

@property (strong, nonatomic) NSNumber *currentKey;

- (void)deleteEvent:(ListEvent *)event;

@end
