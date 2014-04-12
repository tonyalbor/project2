//
//  ListSet.m
//  project2 part 3
//
//  Created by Tony Albor on 4/10/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import "ListSet.h"

@implementation ListSet

#define kEncodeKeyDue        @"kEncodeKeyDue"
#define kEncodeKeyCompleted  @"kEncodeKeyCompleted"
#define kEncodeKeyDeleted    @"kEncodeKeyDeleted"

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.due forKey:kEncodeKeyDue];
    [aCoder encodeObject:self.completed forKey:kEncodeKeyCompleted];
    [aCoder encodeObject:self.deleted forKey:kEncodeKeyDeleted];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if ((self = [super init])) {
        self.due = [aDecoder decodeObjectForKey:kEncodeKeyDue];
        self.completed = [aDecoder decodeObjectForKey:kEncodeKeyCompleted];
        self.deleted = [aDecoder decodeObjectForKey:kEncodeKeyDeleted];
    }
    
    return self;
}

@end
