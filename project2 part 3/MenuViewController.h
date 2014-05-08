//
//  MenuViewController.h
//  project2 part 3
//
//  Created by Tony Albor on 5/7/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuViewControllerDelegate;

@interface MenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) id<MenuViewControllerDelegate>delegate;

- (void)setDelegate:(id<MenuViewControllerDelegate>)delegate;

@end

@protocol MenuViewControllerDelegate <NSObject>

- (void)didSelectListSetAtIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectAddSet;

@end
