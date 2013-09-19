//
//  ViewController.h
//  project2 part 3
//
//  Created by Tony Albor on 9/8/13.
//  Copyright (c) 2013 tonyalbor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListEvent.h"
#import "ListEventCell.h"
#import "ListEventDataSource.h"
#import "CustomCellColor.h"
#import "DetailViewController.h"

@interface ListEventViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) ListEventDataSource *sharedDataSource;

@property (weak, nonatomic) IBOutlet UIView *containerView;


@end
