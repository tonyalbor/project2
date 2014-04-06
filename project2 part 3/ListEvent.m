//
//  ListEvent.m
//  project2 part 3
//
//  Created by Tony Albor on 9/8/13.
//  Copyright (c) 2013 tonyalbor. All rights reserved.
//

#import "ListEvent.h"

@implementation ListEvent

@synthesize title;
@synthesize date;
@synthesize categoryID;


#define kEncodeKeyTitle       @"kEncodeKeyTitle"
#define kEncodeKeyDate        @"kEncodeKeyDate"
#define kEncodeKeyCategoryId  @"kEncodeKeyCategoryId"

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.title forKey:kEncodeKeyTitle];
    [aCoder encodeObject:self.date forKey:kEncodeKeyDate];
    [aCoder encodeInt:self.categoryID.intValue forKey:kEncodeKeyCategoryId];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if ((self = [super init])) {
        self.title = [aDecoder decodeObjectForKey:kEncodeKeyTitle];
        self.date = [aDecoder decodeObjectForKey:kEncodeKeyDate];
        self.categoryID = @([aDecoder decodeIntForKey:kEncodeKeyCategoryId]);
    }
    
    return self;
}

- (id)init {
    if(!self) {
        // inititalization
        title = @"";
        date = @"";
        categoryID = @0;
    }
    return self;
}

- (void)changeColor {
    if(categoryID.integerValue == 99) categoryID = @0;
    if(categoryID.integerValue == 8) categoryID = @0;
    else {
        NSInteger temp = categoryID.integerValue;
        ++temp;
        categoryID = [NSNumber numberWithInteger:temp];
    }
    
}

@end
