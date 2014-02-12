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

static CGFloat cellHeight = 80;

#pragma mark UITableViewDataSource

- (IBAction)segmentedControlValueDidChange:(UISegmentedControl *)sender {
    //[sharedDataSource setCurrentList:@([sender selectedSegmentIndex])];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"current category: %@",[sharedDataSource currentKey]);
    
    int n = 0;
    for(NSNumber *key in sharedDataSource.events) {
        NSArray *a = [sharedDataSource.events objectForKey:key];
        for(id object in a) {
            ++n;
        }
    }

    NSLog(@"number in actual shit: %d",n);
    NSLog(@"fake num: %d",sharedDataSource.eventsAddedToAll.count);
    
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
    
    ListEvent *event = [events objectAtIndex:indexPath.row];
    // date still unimplemented
    //[cell.dateLabel setText:event.date];
    [cell.dateLabel setHidden:YES];
    [cell.eventLabel setText:event.title];
    
    if(event.categoryID == nil || [event.categoryID isEqualToNumber:@99]) event.categoryID = @0;
    //NSLog(@"category id for event: %@",event.categoryID);
    
    CustomCellColor *backgroundColor = [CustomCellColor colorForId:[event.categoryID isEqualToNumber:@99] ? @0 : event.categoryID];
    cell.backgroundColor = [backgroundColor customCellColorToUIColor];
    
   
    
    if(cell.gestureRecognizers.count != 4) {
        // 4 is the number of recognizers I'd like to add
        // if there are 4 recognizers for the cell, then there
        // is no need to add them again
        // (since this method gets called a lotttt)
        
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
}

- (void)deleteAllEventsFromTableView {
    for(int i = 0; i < [self.tableView numberOfRowsInSection:0]; ++ i) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
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

- (IBAction)switchCategory:(UISwipeGestureRecognizer *)gestureRecognizer {
    // called when swiped left/right
    [sharedDataSource organizeEvents];
    
    if([[sharedDataSource events] count] <= 1) return;
    
    [self.tableView beginUpdates];
    [self switchCategoryWithDirection:gestureRecognizer.direction];
    [self.tableView endUpdates];
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
    
    // save data doe
    //[sharedDataSource saveData];
}

- (IBAction)showMenu:(UILongPressGestureRecognizer *)sender {
    
    if(sender.state == UIGestureRecognizerStateBegan ) {
        NSLog(@"menu doe");
        UIView *mask = [[UIView alloc] initWithFrame:self.containerView.frame];
        [mask setHidden:YES];
        [mask setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
        
        [self.containerView insertSubview:mask atIndex:0];
        
        [UIView animateWithDuration:.3 animations:^{
            [mask setHidden:NO];
            [mask setAlpha:.8];
            self.containerView.alpha = 1;
        }];
    } else if(sender.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:.5 animations:^{
            [[self.containerView.subviews objectAtIndex:0] setAlpha:0];
            //[[self.view.subviews objectAtIndex:self.view.subviews.count-2] removeFromSuperview];
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
    
    //NSNumber *oldKey = event.categoryID;
    [event changeColor];
    //NSNumber *newKey = event.categoryID;
    
    
    
    [self.tableView reloadData];
    //[sharedDataSource changeKeyFor:event fromKey:oldKey toKey:newKey];
    NSLog(@"events now: %@",sharedDataSource.events);
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

- (void)pinchedCells:(UIPinchGestureRecognizer *)gestureRecongnizer {
    UIGestureRecognizerState pinchState = gestureRecongnizer.state;
    
    if(pinchState == UIGestureRecognizerStateRecognized) {
        NSLog(@"recognized pinch");
    } else if(pinchState == UIGestureRecognizerStateChanged) {
        // this is where it all should happen
        NSLog(@"changed pinch");
        if([self didPinchInwards:gestureRecongnizer]) {
            // make cells smaller
            if(cellHeight >= 40) {
                cellHeight -= 1;
            }
        } else if([self didPinchOutwards:gestureRecongnizer]) {
            // make cells larger
            if(cellHeight <= 100) {
                cellHeight += 1;
            }
        }
        [self.tableView reloadData];
    } else if(pinchState == UIGestureRecognizerStateEnded) {
        
    }
}

/*
 
 these two methods need to be changed
 i believe the problem is that the scale
 is based off of the initial two points
 where the pinch started
 
 */
- (BOOL)didPinchInwards:(UIPinchGestureRecognizer *)pinchRecognizer {
    return pinchRecognizer.scale < 1;
}

- (BOOL)didPinchOutwards:(UIPinchGestureRecognizer *)pinchRecognizer {
    return pinchRecognizer.scale > 1;
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
    
    // pinch stuff
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] init];
    [pinchRecognizer addTarget:self action:@selector(pinchedCells:)];
    [self.tableView addGestureRecognizer:pinchRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark helper functions

- (ListEvent *)getEventForIndexPath:(NSIndexPath *)indexPath {
    NSArray *events;
    if([sharedDataSource isDisplayingAllEvents]) {
        events = [sharedDataSource getAllEvents];
    } else {
        events = [sharedDataSource eventsForCurrentKey];
    }
    return [events objectAtIndex:indexPath.row];
}

- (void)switchCategoryWithDirection:(UISwipeGestureRecognizerDirection)direction {
    BOOL shouldIncrement;
    UITableViewRowAnimation insertAnimation;
    UITableViewRowAnimation deleteAnimation;
    
    // determine which direction to insert/delete
    if(direction == UISwipeGestureRecognizerDirectionLeft) {
        shouldIncrement = NO;
        deleteAnimation = UITableViewRowAnimationLeft;
        insertAnimation = UITableViewRowAnimationRight;
    } else if(direction == UISwipeGestureRecognizerDirectionRight) {
        shouldIncrement = YES;
        insertAnimation = UITableViewRowAnimationLeft;
        deleteAnimation = UITableViewRowAnimationRight;
    }
    
    // delete rows
    int numOfCells = [self.tableView numberOfRowsInSection:0];
    for(int i = 0; i < numOfCells; ++i) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:deleteAnimation];
    }
    
    // increment/decrement key
    if(shouldIncrement) [sharedDataSource incrementCurrentKey];
    else [sharedDataSource decrementCurrentKey];
    
    // insert rows
    NSArray *arr = [sharedDataSource eventsForCurrentKey];
    NSIndexPath *indexPath;
    for(int i = 0; i < arr.count; ++i) {
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:insertAnimation];
    }
}

@end
