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
#import <WYPopoverController.h>
#import "MenuViewController.h"

@class ListSetDataSource;

@interface ListEventViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, ListEventCellDelegate, WYPopoverControllerDelegate, MenuViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *deletedImageView;
@property (weak, nonatomic) IBOutlet UIView *eventsImageView;
@property (weak, nonatomic) IBOutlet UIView *completedImageView;

@property (strong, nonatomic) IBOutlet UITextField *titleTextField;

@property (strong, nonatomic) NSMutableArray *cells;

@property (strong, nonatomic) ListSetDataSource *listSetDataSource;

@property (strong, nonatomic) UITapGestureRecognizer *tableViewTapRecognizer;

@end
