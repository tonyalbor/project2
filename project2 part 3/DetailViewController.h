//
//  DetailViewController.h
//  project2 part 3
//
//  Created by Tony Albor on 9/19/13.
//  Copyright (c) 2013 tonyalbor. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DATE,
    REMINDER,
    NOTES
} detailSegments;

@interface DetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *setTimeButton;

+ (void)setColor:(UIColor *)cellBackgroundColor;

@end
