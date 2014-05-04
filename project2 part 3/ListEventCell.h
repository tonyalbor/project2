//
//  ListEventCell.h
//  project2 part 3
//
//  Created by Tony Albor on 9/8/13.
//  Copyright (c) 2013 tonyalbor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCellColor.h"

@protocol ListEventCellDelegate;

@interface ListEventCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (strong, nonatomic) id<ListEventCellDelegate>delegate;

- (void)initWithGestureRecognizers;

@end

@protocol ListEventCellDelegate <NSObject>

- (void)cellPanned:(UIPanGestureRecognizer *)gestureRecognizer shouldComplete:(BOOL)shouldComplete shouldDelete:(BOOL)shouldDelete;
- (void)cellTapped:(UITapGestureRecognizer *)gestureRecognizer;
- (void)cellLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer;

@end