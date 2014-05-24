//
//  ListEvent.m
//  project2 part 3
//
//  Created by Tony Albor on 9/8/13.
//  Copyright (c) 2013 tonyalbor. All rights reserved.
//

#import "ListEvent.h"
#import "CustomCellColor.h"
#import "ListSet.h"
#import "ListSetDataSource.h"

@implementation ListEvent

@synthesize title;
@synthesize dateString;
@synthesize date;
@synthesize categoryID;
@synthesize sortId;


#define kEncodeKeyTitle       @"kEncodeKeyTitle"
#define kEncodeKeyDate        @"kEncodeKeyDate"
#define kEncodeKeyCategoryId  @"kEncodeKeyCategoryId"
#define kEncodeKeySortId      @"kEncodeKeySortId"

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.title forKey:kEncodeKeyTitle];
    [aCoder encodeObject:self.date forKey:kEncodeKeyDate];
    [aCoder encodeInt:self.categoryID.intValue forKey:kEncodeKeyCategoryId];
    [aCoder encodeObject:self.categoryID forKey:kEncodeKeySortId];

}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if ((self = [super init])) {
        self.title = [aDecoder decodeObjectForKey:kEncodeKeyTitle];
        self.date = [aDecoder decodeObjectForKey:kEncodeKeyDate];
        self.categoryID = @([aDecoder decodeIntForKey:kEncodeKeyCategoryId]);
        self.sortId = [aDecoder decodeObjectForKey:kEncodeKeySortId];
    }
    
    return self;
}

- (id)init {
    if(self) {
        // inititalization
        title = @"";
        dateString = @"";
        categoryID = @0;
        sortId = @0;
    }
    return self;
}

- (void)changeColor {
    if(categoryID.integerValue == 99) categoryID = @0;
    if(categoryID.integerValue == [[CustomCellColor numberOfCustomColors] intValue]) categoryID = @0;
    else {
        NSInteger temp = categoryID.integerValue;
        ++temp;
        categoryID = [NSNumber numberWithInteger:temp];
    }
    //sortId = @([[[ListSetDataSource sharedDataSource] listSetForCurrentKey] numberOfEventsInDue] -1);// index of last item from categoryid
}

@end
