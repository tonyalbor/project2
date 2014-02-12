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
#import "CustomCellColor.h"
#import "DetailViewController.h"

@class ListEventDataSource;
@class CompletedDataSource;
@class DeletedDataSource;

@interface ListEventViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) ListEventDataSource *eventDataSource;
@property (strong, nonatomic) CompletedDataSource *completedDataSource;
@property (strong, nonatomic) DeletedDataSource *deletedDataSource;

@property (weak, nonatomic) IBOutlet UIView *containerView;


@end
