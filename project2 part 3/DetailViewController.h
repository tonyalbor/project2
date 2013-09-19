//
//  DetailViewController.h
//  project2 part 3
//
//  Created by Tony Albor on 9/19/13.
//  Copyright (c) 2013 tonyalbor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *seg;

+ (void)setColor:(UIColor *)cellBackgroundColor;

@end
