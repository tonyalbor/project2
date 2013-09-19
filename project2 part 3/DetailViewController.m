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

static UIColor *color = nil;

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

- (void)viewDidLoad {
    if(color != nil) {
        self.view.backgroundColor = color;
    } else NSLog(@"not setting that color");
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
