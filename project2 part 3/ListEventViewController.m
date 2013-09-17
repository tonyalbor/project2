//
//  ViewController.m
//  project2 part 3
//
//  Created by Tony Albor on 9/8/13.
//  Copyright (c) 2013 tonyalbor. All rights reserved.
//

#import "ListEventViewController.h"

@interface ListEventViewController ()

@end

@implementation ListEventViewController

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"current category: %@",[[ListEventDataSource sharedDataSource] currentKey]);
    return [[ListEventDataSource sharedDataSource] numberOfEventsForCurrentKey];
}

- (ListEventCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ListEventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listEventCell"];
    if(cell == nil) {
        cell = [[ListEventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"listEventCell"];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // might use later for dragging/reorder cells
}

- (void)configureCell:(ListEventCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    ListEventDataSource *sharedDataSource = [ListEventDataSource sharedDataSource];
    NSNumber *currentKey = [sharedDataSource currentKey];
    
    NSArray *events;
    
    BOOL allEventsShown = [sharedDataSource isDisplayingAllEvents];
    
    if(allEventsShown) {
        events = [sharedDataSource getAllEvents];
    } else {
        events = [[sharedDataSource events] objectForKey:currentKey];
    }
    
    ListEvent *event = [events objectAtIndex:indexPath.row];
    // date still unimplemented
    //[cell.dateLabel setText:event.date];
    [cell.dateLabel setHidden:YES];
    [cell.eventLabel setText:event.title];
    NSLog(@"category id for event: %@",event.categoryID);
    if(event.categoryID == nil || [event.categoryID isEqualToNumber:@99]) event.categoryID = @0;
    
    CustomCellColor *backgroundColor = [CustomCellColor colorForId:[event.categoryID isEqualToNumber:@99] ? @0 : event.categoryID];
    cell.backgroundColor = [UIColor colorWithRed:backgroundColor.red green:backgroundColor.green blue:backgroundColor.blue alpha:1];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] init];
    [leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [leftSwipe addTarget:self action:@selector(swipedCell:)];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] init];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [rightSwipe addTarget:self action:@selector(swipedCell:)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(tappedCell:)];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
    [longPress addTarget:self action:@selector(longPressedCell:)];
    
    [cell addGestureRecognizer:leftSwipe];
    [cell addGestureRecognizer:rightSwipe];
    [cell addGestureRecognizer:tap];
    [cell addGestureRecognizer:longPress];
}

- (void)deleteAllEventsFromTableView {
    [self.tableView beginUpdates];
    for(int i = 0; i < [self.tableView numberOfRowsInSection:0]; ++ i) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
    [self.tableView endUpdates];
}

- (void)insertRowAtBottomOfTableView {
    NSInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numberOfRows inSection:0];
    
    [self.tableView beginUpdates];
    [[ListEventDataSource sharedDataSource] addEvent:[ListEvent new]];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
}

- (void)bringUpKeyboardForNewEvent {
    NSInteger newCellIndex = [self.tableView numberOfRowsInSection:0] - 1;
    NSIndexPath *newCellIndexPath = [NSIndexPath indexPathForRow:newCellIndex inSection:0];
    ListEventCell *newCell = (ListEventCell *)[self.tableView cellForRowAtIndexPath:newCellIndexPath];
    ListEventDataSource *sharedDataSource = [ListEventDataSource sharedDataSource];
    
    ListEvent *event = [sharedDataSource recentlyAddedEvent];
    event.categoryID = [[ListEventDataSource sharedDataSource] currentKey];
    
    BOOL createWhiteCell = [sharedDataSource isDisplayingAllEvents];
    
    newCell.cellColor = [CustomCellColor colorForId:createWhiteCell ? @0 : event.categoryID];
    //[self.tableView reloadData];
    [newCell.textField setEnabled:YES];
    [newCell.textField becomeFirstResponder];
}

- (void)deleteSwipedCell:(ListEvent *)event atIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)direction {
    [self.tableView beginUpdates];
    //[[ListEventDataSource sharedDataSource] removeEventAtIndexPath:indexPath];
    [[ListEventDataSource sharedDataSource] removeEvent:event];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:direction];
    [self.tableView endUpdates];
}

#pragma mark IBActions

- (IBAction)pullUp:(id)sender {
    NSLog(@"pulled up");
    
    [self insertRowAtBottomOfTableView];
    NSLog(@"1");
    [self bringUpKeyboardForNewEvent];
    NSLog(@"2");
}

- (IBAction)switchCategory:(UISwipeGestureRecognizer *)gestureRecognizer {
    // called when swiped left/right
    [[ListEventDataSource sharedDataSource] organizeEvents];
    
    [self.tableView beginUpdates];
    if(gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        int numOfCells = [self.tableView numberOfRowsInSection:0];
        for(int i = 0; i < numOfCells; ++i) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }

        [[ListEventDataSource sharedDataSource] decrementCurrentKey];
        NSArray *arr = [[ListEventDataSource sharedDataSource] eventsForCurrentKey];
        NSIndexPath *indexPath;
        for(int i = 0; i < arr.count; ++i) {
            indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        }

        
    } else if(gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        int numOfCells = [self.tableView numberOfRowsInSection:0];
        for(int i = 0; i < numOfCells; ++i) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        }
        [[ListEventDataSource sharedDataSource] incrementCurrentKey];
        NSArray *arr = [[ListEventDataSource sharedDataSource] eventsForCurrentKey];
        NSIndexPath *indexPath;
        for(int i = 0; i < arr.count; ++i) {
            indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
    [self.tableView endUpdates];
    //[self.tableView reloadData];
}

- (IBAction)showAllEvents:(id)sender {
    // called when double tapped
    [[ListEventDataSource sharedDataSource] organizeEvents];
    [[ListEventDataSource sharedDataSource] displayAllEvents];
    [self.tableView reloadData];
}

#pragma mark UIGestureRecognizer

- (void)swipedCell:(UISwipeGestureRecognizer *)gestureRecognizer {
    UISwipeGestureRecognizerDirection swipeDirection = gestureRecognizer.direction;
    ListEventCell *cell = (ListEventCell *)gestureRecognizer.view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ListEvent *eventToBeRemoved = [self getEventForIndexPath:indexPath];
    
    if(swipeDirection == UISwipeGestureRecognizerDirectionLeft) {
        [self deleteSwipedCell:eventToBeRemoved atIndexPath:indexPath withRowAnimation:UITableViewRowAnimationLeft];
    } else if(swipeDirection == UISwipeGestureRecognizerDirectionRight) {
        [self deleteSwipedCell:eventToBeRemoved atIndexPath:indexPath withRowAnimation:UITableViewRowAnimationRight];
    } else {
        // wait, what
    }

}

- (void)tappedCell:(UITapGestureRecognizer *)gestureRecognizer {
    NSLog(@"tapped cell");
    ListEventCell *cell = (ListEventCell *)gestureRecognizer.view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ListEvent *event = [self getEventForIndexPath:indexPath];
    
    [event changeColor];
    [self.tableView reloadData];
}

- (void)longPressedCell:(UILongPressGestureRecognizer *)gesutureRecognizer {
    [self.tableView setEditing:YES animated:1];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    ListEvent *newEvent = [[ListEventDataSource sharedDataSource] recentlyAddedEvent];
    newEvent.title = textField.text;
    [self.tableView reloadData];
    textField.text = @"";
    [textField setEnabled:NO];
    [textField resignFirstResponder];
  
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    ListEventCell *cell = (ListEventCell *)textField.superview.superview.superview;
    return cell.eventLabel.text.length == 0;
}

#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (ListEvent *)getEventForIndexPath:(NSIndexPath *)indexPath {
    ListEventDataSource *sharedDataSource = [ListEventDataSource sharedDataSource];
    NSArray *events;
    if([sharedDataSource isDisplayingAllEvents]) {
        events = [sharedDataSource getAllEvents];
    } else {
        events = [sharedDataSource eventsForCurrentKey];
    }
    return [events objectAtIndex:indexPath.row];
}

@end
