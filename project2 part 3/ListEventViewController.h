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

@class CurrentListHandler;

@class MemoryDataSource;

@interface ListEventViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) ListEventDataSource *eventDataSource;
@property (strong, nonatomic) CompletedDataSource *completedDataSource;
@property (strong, nonatomic) DeletedDataSource *deletedDataSource;

@property (strong, nonatomic) CurrentListHandler *listHandler;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UIImageView *deletedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *eventsImageView;
@property (weak, nonatomic) IBOutlet UIImageView *completedImageView;

@end
