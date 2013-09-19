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

@synthesize sharedDataSource;

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"current category: %@",[sharedDataSource currentKey]);
    self.title = [NSString stringWithFormat:@"@%@",[sharedDataSource currentKey]];
    return [sharedDataSource numberOfEventsForCurrentKey];
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
    NSNumber *currentKey = [sharedDataSource currentKey];
    
    NSArray *events;
    
    BOOL allEventsShown = [sharedDataSource isDisplayingAllEvents];
    
    if(allEventsShown) {
        events = [sharedDataSource getAllEvents];
    } else {
        events = [[sharedDataSource events] objectForKey:currentKey];
    }
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width+10, 30, 40, 40)];
    [button setTitle:@"ni" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor redColor]];
    [cell.contentView addSubview:button];
    
    ListEvent *event = [events objectAtIndex:indexPath.row];
    // date still unimplemented
    //[cell.dateLabel setText:event.date];
    [cell.dateLabel setHidden:YES];
    [cell.eventLabel setText:event.title];
    
    if(event.categoryID == nil || [event.categoryID isEqualToNumber:@99]) event.categoryID = @0;
    //NSLog(@"category id for event: %@",event.categoryID);
    
    CustomCellColor *backgroundColor = [CustomCellColor colorForId:[event.categoryID isEqualToNumber:@99] ? @0 : event.categoryID];
    cell.backgroundColor = [backgroundColor customCellColorToUIColor];
    
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
    //[self.tableView beginUpdates];
    for(int i = 0; i < [self.tableView numberOfRowsInSection:0]; ++ i) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
    //[self.tableView endUpdates];
}

- (void)insertRowAtBottomOfTableView {
    NSInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numberOfRows inSection:0];
    
    [self.tableView beginUpdates];
    [sharedDataSource addEvent:[ListEvent new]];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
}

- (void)bringUpKeyboardForNewEvent {
    NSInteger newCellIndex = [self.tableView numberOfRowsInSection:0] - 1;
    NSIndexPath *newCellIndexPath = [NSIndexPath indexPathForRow:newCellIndex inSection:0];
    ListEventCell *newCell = (ListEventCell *)[self.tableView cellForRowAtIndexPath:newCellIndexPath];
    
    // can also try recentlyAddedEvent
    ListEvent *event = [self getEventForIndexPath:newCellIndexPath];
    event.categoryID = [sharedDataSource currentKey];
    if([event.categoryID isEqualToNumber:@99]) {
        event.categoryID = @0;
    }
    //BOOL createWhiteCell = [sharedDataSource isDisplayingAllEvents];
    
    newCell.cellColor = [CustomCellColor colorForId:/*createWhiteCell ? @0 : */event.categoryID];
    //[self.tableView reloadData];
    [newCell.textField setEnabled:YES];
    [newCell.textField becomeFirstResponder];
}

- (void)deleteSwipedCell:(ListEvent *)event atIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)direction {
    [self.tableView beginUpdates];
    [sharedDataSource removeEvent:event];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:direction];
    [self.tableView endUpdates];
}

- (void)scrollToBottomOfTableView {
    /*NSInteger numOfCells = [self.tableView numberOfRowsInSection:0];
    if(numOfCells > 1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numOfCells-1) inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }*/
}

- (void)adjustTableViewForInsertion {
    //self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 200, 0);
    //self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 200, 0);
}

- (void)readjustTableViewBackToNormal {
    //self.tableView.contentInset = UIEdgeInsetsZero;
    //self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

#pragma mark IBActions

- (IBAction)pullUp:(id)sender {
    NSLog(@"pulled up");
    
    [self adjustTableViewForInsertion];
    [self scrollToBottomOfTableView];
    [self insertRowAtBottomOfTableView];
    [self bringUpKeyboardForNewEvent];
}

- (void)switchCategoryToTheLeft {
    int numOfCells = [self.tableView numberOfRowsInSection:0];
    for(int i = 0; i < numOfCells; ++i) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
    
    [sharedDataSource decrementCurrentKey];
    NSArray *arr = [sharedDataSource eventsForCurrentKey];
    NSIndexPath *indexPath;
    for(int i = 0; i < arr.count; ++i) {
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
}

- (IBAction)switchCategory:(UISwipeGestureRecognizer *)gestureRecognizer {
    // called when swiped left/right
    [sharedDataSource organizeEvents];
    
    if([[sharedDataSource events] count] <= 1) return;
    
    [self.tableView beginUpdates];
    if(gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        /*int numOfCells = [self.tableView numberOfRowsInSection:0];
        for(int i = 0; i < numOfCells; ++i) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }

        [sharedDataSource decrementCurrentKey];
        NSArray *arr = [sharedDataSource eventsForCurrentKey];
        NSIndexPath *indexPath;
        for(int i = 0; i < arr.count; ++i) {
            indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        }*/
        [self switchCategoryToTheLeft];
        
    } else if(gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        [self switchCategoryToTheRight];
    }
    [self.tableView endUpdates];
    //[self.tableView reloadData];
}

- (void)switchCategoryToTheRight {
    int numOfCells = [self.tableView numberOfRowsInSection:0];
    for(int i = 0; i < numOfCells; ++i) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
    [sharedDataSource incrementCurrentKey];
    NSArray *arr = [sharedDataSource eventsForCurrentKey];
    NSIndexPath *indexPath;
    for(int i = 0; i < arr.count; ++i) {
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (IBAction)showAllEvents:(id)sender {
    // called when double tapped
    if([[sharedDataSource events] count] <= 1) return;
    
    if(![sharedDataSource isDisplayingAllEvents]) {
        [self.tableView beginUpdates];
        [self deleteAllEventsFromTableView];
        [sharedDataSource organizeEvents];
        [sharedDataSource displayAllEvents];
        
        NSArray *allEvents = [sharedDataSource getAllEvents];
        for(int i = 0; i < allEvents.count; ++i)  {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        }
        [self.tableView endUpdates];
    }
}

- (IBAction)showMenu:(UILongPressGestureRecognizer *)sender {
    if(sender.state == UIGestureRecognizerStateBegan ) {
        NSLog(@"menu doe");
        [UIView animateWithDuration:.3 animations:^{
            self.containerView.alpha = 1;
        }];
    } else if(sender.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:.5 animations:^{
            self.containerView.alpha = 0;
        }];
        CGPoint point = [sender locationInView:self.containerView];

        NSLog(@"x:%.02lf y:%.02lf",point.x,point.y);
    }
    
}

#pragma mark Menu Options

- (IBAction)hitButton:(id)sender {
    NSLog(@"hit");
  
    self.containerView.hidden = YES;
    [UIView animateWithDuration:.5 animations:^{
        self.containerView.alpha = 0;
    }];
}


#pragma mark ListEventCell UIGestureRecognizer

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
    //[self.tableView setEditing:YES animated:1];
    NSLog(@"long press");
    if(gesutureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"got in");
        ListEventCell *cell = (ListEventCell *)gesutureRecognizer.view;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        ListEvent *event = [self getEventForIndexPath:indexPath];
        CustomCellColor *color = [CustomCellColor colorForId:event.categoryID];
        UIColor *colorcolor = [color customCellColorToUIColor];
        [DetailViewController setColor:colorcolor];
        DetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
        [self.navigationController pushViewController:detail animated:YES];
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self readjustTableViewBackToNormal];
    [self scrollToBottomOfTableView];
    
    ListEvent *newEvent = [sharedDataSource recentlyAddedEvent];
    newEvent.title = textField.text;
    [self.tableView reloadData];
    textField.text = @"";
    [textField setEnabled:NO];
    [textField resignFirstResponder];
    //[sharedDataSource organizeEvents];
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    UIView *view = textField.superview;
    while(![view isKindOfClass:[ListEventCell class]]) {
        // keep getting textfield's superview until it is the ListEventCell
        // i think on ios 6 and ios 7 they have a different heirarchy
        // but eventually it'll get there
        view = view.superview;
    }
    ListEventCell *cell = (ListEventCell *)view;
    return cell.eventLabel.text.length == 0;
}

#pragma mark UIViewController

- (void)viewDidLoad {
    self.containerView.alpha = 0;
    sharedDataSource = [ListEventDataSource sharedDataSource];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (ListEvent *)getEventForIndexPath:(NSIndexPath *)indexPath {
    NSArray *events;
    if([sharedDataSource isDisplayingAllEvents]) {
        events = [sharedDataSource getAllEvents];
    } else {
        events = [sharedDataSource eventsForCurrentKey];
    }
    return [events objectAtIndex:indexPath.row];
}

@end
