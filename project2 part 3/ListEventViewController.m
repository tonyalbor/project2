//
//  ViewController.m
//  project2 part 3
//
//  Created by Tony Albor on 9/8/13.
//  Copyright (c) 2013 tonyalbor. All rights reserved.
//

#import "ListEventViewController.h"
#import "ListEventDataSource.h"
#import "CompletedDataSource.h"
#import "DeletedDataSource.h"

@interface ListEventViewController ()

@end

@implementation ListEventViewController

@synthesize eventDataSource;
@synthesize completedDataSource;
@synthesize deletedDataSource;

static CGFloat cellHeight = 80;

// ADD MORE TO THIS
// ADD MORE TO THIS
// ADD MORE TO THIS
static BOOL isInCreateMode = YES;

#pragma mark UITableViewDataSource

- (IBAction)segmentedControlValueDidChange:(UISegmentedControl *)sender {
    //[eventDataSource setCurrentList:@([sender selectedSegmentIndex])];
    
    
    // 0 - deleted
    // 1 - events
    // 2 - completed
    
    /*
     
     IDEA TIME
     ---------
     
     Maybe instead of the segmented control,
     I can just have three circles at the bottom,
     one for each list (deleted, events, completed).
     
     And then you can touch one to go to that list.
     
     Oh, and being able to change the name of a category would be cool.
     It would work like this:
     
        Tap on the navigation item title and enter the name from there.
     
     And then just make sure that everywhere where I have been doing:
     
        for(NSNumber *key in events) ...
     
     I would need to change it to:
     
        for(id key in events) ...
     
     That way the key can be either a user-entered string, or just an NSNumber *
     
     */
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //self.title = [NSString stringWithFormat:@"@%@",[eventDataSource currentKey]];
    return [eventDataSource numberOfEventsForCurrentKey];
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
    NSNumber *currentKey = [eventDataSource currentKey];
    
    NSArray *events;
    
    BOOL allEventsShown = [eventDataSource isDisplayingAllEvents];
    
    if(allEventsShown) {
        events = [eventDataSource getAllEvents];
    } else {
        events = [[eventDataSource events] objectForKey:currentKey];
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
    [eventDataSource addEvent:[ListEvent new]];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
}

- (void)bringUpKeyboardForNewEvent {
    NSInteger newCellIndex = [self.tableView numberOfRowsInSection:0] - 1;
    NSIndexPath *newCellIndexPath = [NSIndexPath indexPathForRow:newCellIndex inSection:0];
    ListEventCell *newCell = (ListEventCell *)[self.tableView cellForRowAtIndexPath:newCellIndexPath];
    
    // can also try recentlyAddedEvent
    ListEvent *event = [self getEventForIndexPath:newCellIndexPath];
    event.categoryID = [eventDataSource currentKey];
    if([event.categoryID isEqualToNumber:@99]) {
        event.categoryID = @0;
    }
   
    [newCell.textField setEnabled:YES];
    [newCell.textField becomeFirstResponder];
}

- (void)deleteSwipedCell:(ListEvent *)event atIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)direction {
    [self.tableView beginUpdates];
    [eventDataSource removeEvent:event];
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
    if(!isInCreateMode) return;
    
    [self adjustTableViewForInsertion];
    [self scrollToBottomOfTableView];
    [self insertRowAtBottomOfTableView];
    [self bringUpKeyboardForNewEvent];
}

- (IBAction)switchCategory:(UISwipeGestureRecognizer *)gestureRecognizer {
    // called when swiped left/right
    [eventDataSource organizeEvents];
    
    if([[eventDataSource events] count] <= 1) return;
    
    [self.tableView beginUpdates];
    [self switchCategoryWithDirection:gestureRecognizer.direction];
    [self.tableView endUpdates];
}

- (IBAction)showAllEvents:(id)sender {
    // called when double tapped
    if([[eventDataSource events] count] <= 1) return;
    
    if(![eventDataSource isDisplayingAllEvents]) {
        [self.tableView beginUpdates];
        [self deleteAllEventsFromTableView];
        [eventDataSource organizeEvents];
        [eventDataSource displayAllEvents];
        
        NSArray *allEvents = [eventDataSource getAllEvents];
        for(int i = 0; i < allEvents.count; ++i)  {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        }
        [self.tableView endUpdates];
    }
    
    // save data doe
    //[eventDataSource saveData];
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
    //[eventDataSource changeKeyFor:event fromKey:oldKey toKey:newKey];
    NSLog(@"events now: %@",eventDataSource.events);
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
    
    ListEvent *newEvent = [eventDataSource recentlyAddedEvent];
    newEvent.title = textField.text;
    [self.tableView reloadData];
    textField.text = @"";
    [textField setEnabled:NO];
    [textField resignFirstResponder];
    //[eventDataSource organizeEvents];
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
    
    // mmmm data
    eventDataSource = [ListEventDataSource sharedDataSource];
    completedDataSource = [CompletedDataSource sharedDataSource];
    deletedDataSource = [DeletedDataSource sharedDataSource];
    
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
    if([eventDataSource isDisplayingAllEvents]) {
        events = [eventDataSource getAllEvents];
    } else {
        events = [eventDataSource eventsForCurrentKey];
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
    if(shouldIncrement) [eventDataSource incrementCurrentKey];
    else [eventDataSource decrementCurrentKey];
    
    // insert rows
    NSArray *arr = [eventDataSource eventsForCurrentKey];
    NSIndexPath *indexPath;
    for(int i = 0; i < arr.count; ++i) {
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:insertAnimation];
    }
}

@end
