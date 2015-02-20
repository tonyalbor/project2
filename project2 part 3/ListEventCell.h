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

@interface ListEventCell : UITableViewCell <UIGestureRecognizerDelegate, UITextFieldDelegate>

// user interface
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (weak, nonatomic) UIView *datePicker;

// delegate to send ListEventCellDelegate messages to
@property (strong, nonatomic) id<ListEventCellDelegate>delegate;

// cell gesture recognizers
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

// initialize all gesture recognizers for cell
- (void)initWithGestureRecognizers;

// handle the panning gesture for each cell
- (void)pannedCell:(UIPanGestureRecognizer *)gestureRecognizer;

// current index of expanded cell
+ (int)selectedIndex;

// set selected index after long-pressing a cell
+ (void)setSelectedIndex:(int)index;

// get cell height
- (CGFloat)cellHeight;

// set cell height
- (void)setCellHeight:(CGFloat)height;

// is cell currently expanded
- (BOOL)isExpanded;

// set cell to expanded
- (void)setExpanded:(BOOL)expanded;

- (void)addSubviews;
- (void)removeSubviews;

- (void)swipeOffScreenInDirection:(UITableViewRowAnimation)direction atIndexPath:(NSIndexPath *)indexPath;

@end

#pragma mark ListEventCellDelegate methods

@protocol ListEventCellDelegate <NSObject>

- (void)didBeginPanningCell:(ListEventCell *)cell;

- (void)didPanCellTo:(CGFloat)xValue;
- (void)didPanCellAmount:(CGFloat)amount;
- (void)didStopPanningCell:(ListEventCell *)cell;

- (void)cellPanned:(UIPanGestureRecognizer *)gestureRecognizer complete:(BOOL)shouldComplete delete:(BOOL)shouldDelete;
//- (void)cellTapped:(ListEventCell *)cell;
- (void)cellLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer;
- (BOOL)isCreatingNewCell;

- (void)changeCellColor:(ListEventCell *)cell;
- (void)expandCell:(ListEventCell *)cell;
- (void)collapseCell:(ListEventCell *)cell;
- (void)collapseCellAtIndex:(int)index;
- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)didFinishMovingCellOffScreenAtIndexPath:(NSIndexPath *)indexPath;

// TODO :: move this to actual cell model, maybe
//- (void)completeCreationOfEventWith:(UITextField *)textfield;

@end