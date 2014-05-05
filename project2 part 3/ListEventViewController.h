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

@class ListSetDataSource;

@interface ListEventViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, ListEventCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) ListSetDataSource *listSetDataSource;

@property (strong, nonatomic) NSMutableArray *cells;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UIImageView *deletedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *eventsImageView;
@property (weak, nonatomic) IBOutlet UIImageView *completedImageView;

@end
