//
//  DetailViewController.m
//  project2 part 3
//
//  Created by Tony Albor on 9/19/13.
//  Copyright (c) 2013 tonyalbor. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

@synthesize datePicker;
@synthesize setTimeButton;
@synthesize segmentedControl;

static UIColor *color = nil;
static BOOL displayingDatePicker;

+ (void)setColor:(UIColor *)cellBackgroundColor {
    color = cellBackgroundColor;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)setDate:(id)sender {
    NSDate *date;
    NSString *dateString;
    
    date = datePicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    UIButton *button = (UIButton *)sender;
    if([button.titleLabel.text isEqualToString:@"Set Date"]) {
        [dateFormatter setDateFormat:@"MM/dd/yy"];
    } else if([button.titleLabel.text isEqualToString:@"Set Time"]) {
        [dateFormatter setDateFormat:@"hh:mm"];
    }
    
    dateString = [dateFormatter stringFromDate:date];

    NSLog(@"Date: %@",dateString);
}

- (IBAction)segmentedControlDidSwitch:(id)sender {
    
    switch (segmentedControl.selectedSegmentIndex) {
        case DATE:
            [self displayDateSegment];
            break;
        case REMINDER:
            [self displayReminderSegment];
            break;
        case NOTES:
            [self displayNotesSegment];
            break;
        default:
            NSLog(@"whaaaaaaat");
            break;
    }
    [self setUpDatePicker];
}

- (void)setUpDatePicker {
    [datePicker setHidden:!displayingDatePicker];
    [setTimeButton setHidden:!displayingDatePicker];
}

- (void)displayDateSegment {
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [setTimeButton setTitle:@"Set Date" forState:UIControlStateNormal];
    displayingDatePicker = YES;
}

- (void)displayReminderSegment {
    [datePicker setDatePickerMode:UIDatePickerModeTime];
    [setTimeButton setTitle:@"Set Time" forState:UIControlStateNormal];
    displayingDatePicker = YES;
}

- (void)displayNotesSegment {
    displayingDatePicker = NO;
}

- (void)viewDidLoad {
    if(color != nil) {
        self.view.backgroundColor = color;
    } else NSLog(@"not setting that color");
    
    displayingDatePicker = segmentedControl.selectedSegmentIndex != NOTES;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
