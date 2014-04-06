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
#import "CurrentListHandler.h"
#import "MemoryDataSource.h"

@interface ListEventViewController ()

@end

@implementation ListEventViewController

@synthesize eventDataSource;
@synthesize completedDataSource;
@synthesize deletedDataSource;
@synthesize listHandler;

static CGFloat cellHeight = 80;

// ADD MORE TO THIS
// ADD MORE TO THIS
// ADD MORE TO THIS
static BOOL isInCreateMode = YES;

static BOOL keyboardIsUp = NO;

#pragma mark UITableViewDataSource

- (IBAction)segmentedControlValueDidChange:(UISegmentedControl *)sender {
    //[eventDataSource setCurrentList:@([sender selectedSegmentIndex])];
    
    
    // 0 - deleted
    // 1 - events
    // 2 - completed
    
    /*
     
     IDEA TIME
     ---------
     
     Oh, and being able to change the name of a category would be cool.
     It would work like this:
     
        Tap on the navigation item title and enter the name from there.
     
     And then just make sure that everywhere where I have been doing:
     
        for(NSNumber *key in events) ...
     
     I would need to change it to:
     
        for(id key in events) ...
     
     That way the key can be either a user-entered string, or just an NSNumber *
     
    
     ---
     List of lists???
     ---
     
     
     ---
     Maybe have a DataSource class that each other data source can inherit from
     That way, each one of the data source classes does not need to implement a bunch of the same methods,
     e.g. isDisplayingAllEvents, getAllEvents, and so on
     
     I think this would be a good idea, but I'd have to make sure that I do it correctly, maybe one of the
     data source's implementation of a method is slightly different than an other
     ---
     
     */
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //self.title = [NSString stringWithFormat:@"@%@",[eventDataSource currentKey]];
    //return [eventDataSource numberOfEventsForCurrentKey];
    
    return [[listHandler currentListDataSource] numberOfEventsForCurrentKey];
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
    //NSNumber *currentKey = [eventDataSource currentKey];
    id dataSource = [listHandler currentListDataSource];
    NSNumber *currentKey = [dataSource currentKey];
    
    NSArray *events;
    
    //BOOL allEventsShown = [eventDataSource isDisplayingAllEvents];
    BOOL allEventsShown = [dataSource isDisplayingAllEvents];
    
    if(allEventsShown) {
        //events = [eventDataSource getAllEvents];
        events = [dataSource getAllEvents];
    } else {
        //events = [[eventDataSource events] objectForKey:currentKey];
        events = [[dataSource events] objectForKey:currentKey];
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
    
    //
    [cell.textField setTag:indexPath.row];
    
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
    
    for(UIGestureRecognizer *gesture in cell.gestureRecognizers) {
        [gesture setEnabled:[listHandler isInEvents]];
    }
}

- (void)insertEventsFromDataSource:(id)dataSource inDirection:(UITableViewRowAnimation)direction {
    NSNumber *currentKey = [dataSource currentKey];
    NSArray *events;// = [[dataSource events] objectForKey:currentKey];
    
    if([dataSource isDisplayingAllEvents]) {
        events = [dataSource getAllEvents];
    } else {
        events = [[dataSource events] objectForKey:currentKey];
    }
    
    for(int i = 0; i < events.count; ++i) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:direction];
        //ListEvent *event = [events objectAtIndex:i];
    }
}

- (void)deleteAllEventsFromTableViewInDirection:(UITableViewRowAnimation)direction {
    for(int i = 0; i < [self.tableView numberOfRowsInSection:0]; ++ i) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:direction];
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
    keyboardIsUp = YES;
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

#pragma mark UIGestureRecognizer Events

- (IBAction)pullUp:(id)sender {
    if(!isInCreateMode) return;
    
    [self adjustTableViewForInsertion];
    [self scrollToBottomOfTableView];
    [self insertRowAtBottomOfTableView];
    [self bringUpKeyboardForNewEvent];
}

- (id)dataSourceForImageView:(UIImageView *)imageView {
    if([imageView isEqual:_deletedImageView]) return deletedDataSource;
    else if([imageView isEqual:_completedImageView]) return completedDataSource;
    else if([imageView isEqual:_eventsImageView]) return eventDataSource;
    else return nil;
}

- (IBAction)switchCategory:(UISwipeGestureRecognizer *)gestureRecognizer {
    UIImageView *imageView = (UIImageView *)gestureRecognizer.view;
    id dataSource = [self dataSourceForImageView:imageView];
    
    // called when swiped left/right
    [dataSource organizeEvents];
    
    if([[dataSource events] count] <= 1) return;
    
    [self.tableView beginUpdates];
    [self switchCategoryWithDirection:gestureRecognizer.direction andDataSource:dataSource];
    [self.tableView endUpdates];
}

- (IBAction)showAllEvents:(id)sender {
    UITapGestureRecognizer *gestureRecognizer = (UITapGestureRecognizer *)sender;
    UIImageView *imageView = (UIImageView *)gestureRecognizer.view;
    id dataSource = [self dataSourceForImageView:imageView];
    
    // called when double tapped
    if([[dataSource events] count] <= 1) return;
    
    if(![dataSource isDisplayingAllEvents]) {
        [self.tableView beginUpdates];
        [self deleteAllEventsFromTableViewInDirection:UITableViewRowAnimationLeft];
        [dataSource organizeEvents];
        [dataSource displayAllEvents];
        
        NSArray *allEvents = [dataSource getAllEvents];
        for(int i = 0; i < allEvents.count; ++i)  {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        }
        [self.tableView endUpdates];
    }
    
    // currently saving when they double tap
    // tony
    [MemoryDataSource saveAllEvents];
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

- (IBAction)didTapEvents:(id)sender {
    if([[listHandler currentList] isEqualToNumber:@1]) return;
    
    [UIView animateWithDuration:.3 animations:^{
        // big events
        // events (105,468)
        // completed (220,496)
        // deleted (17, 496)
        
        [_eventsImageView setFrame:CGRectMake(105, 468, 110, 100)];
        [_completedImageView setFrame:CGRectMake(220, 496, 80, 72)];
        [_deletedImageView setFrame:CGRectMake(17, 496, 80, 72)];
    }];
    
    UITableViewRowAnimation insertDirection = [self directionToInsert:@1];
    UITableViewRowAnimation deleteDirection = [self directionToDelete:@1];
    
    [listHandler setCurrentList:@1];
    [self.tableView beginUpdates];
    [self deleteAllEventsFromTableViewInDirection:deleteDirection];
    [self insertEventsFromDataSource:eventDataSource inDirection:insertDirection];
    [self.tableView endUpdates];
}

#pragma mark Menu Options

- (IBAction)hitButton:(id)sender {
    NSLog(@"hit");
  
    self.containerView.hidden = YES;
    [UIView animateWithDuration:.5 animations:^{
        self.containerView.alpha = 0;
    }];
}

#pragma mark UIGestureRecongnizer Deleted

- (IBAction)didTapCompleted:(id)sender {
    if([[listHandler currentList] isEqualToNumber:@2]) return;
    
    [UIView animateWithDuration:.3 animations:^{
        // big completed
        // events (105,496)
        // completed (190,468)
        // deleted (17,496)
        
        [_eventsImageView setFrame:CGRectMake(105, 496, 80, 72)];
        [_completedImageView setFrame:CGRectMake(190, 468, 110, 100)];
        [_deletedImageView setFrame:CGRectMake(17, 496, 80, 72)];
    }];
    
    UITableViewRowAnimation insertDirection = [self directionToInsert:@2];
    UITableViewRowAnimation deleteDirection = [self directionToDelete:@2];
    
    [listHandler setCurrentList:@2];
    [self.tableView beginUpdates];
    [self deleteAllEventsFromTableViewInDirection:deleteDirection];
    [self insertEventsFromDataSource:completedDataSource inDirection:insertDirection];
    [self.tableView endUpdates];
}

- (IBAction)didTapDeleted:(id)sender {
    if([[listHandler currentList] isEqualToNumber:@0]) return;
    
    [UIView animateWithDuration:.3 animations:^{
        // big deleted
        // events (132,496)
        // completed (220,496)
        // deleted (20,468)
        
        [_eventsImageView setFrame:CGRectMake(132, 496, 80, 72)];
        [_completedImageView setFrame:CGRectMake(220, 496, 80, 72)];
        [_deletedImageView setFrame:CGRectMake(20, 468, 110, 100)];
    }];
    
    UITableViewRowAnimation insertDirection = [self directionToInsert:@0];
    UITableViewRowAnimation deleteDirection = [self directionToDelete:@0];
    
    [listHandler setCurrentList:@0];
    NSLog(@"%@",[deletedDataSource events]);
    [self.tableView beginUpdates];
    [self deleteAllEventsFromTableViewInDirection:deleteDirection];
    [self insertEventsFromDataSource:deletedDataSource inDirection:insertDirection];
    [self.tableView endUpdates];
    
}


#pragma mark ListEventCell UIGestureRecognizer

- (void)swipedCell:(UISwipeGestureRecognizer *)gestureRecognizer {
    if(![listHandler isInEvents]) {
        return;
    }
    
    
    UISwipeGestureRecognizerDirection swipeDirection = gestureRecognizer.direction;
    ListEventCell *cell = (ListEventCell *)gestureRecognizer.view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ListEvent *eventToBeRemoved = [self getEventForIndexPath:indexPath];
    
    if(swipeDirection == UISwipeGestureRecognizerDirectionLeft) {
        [deletedDataSource deleteEvent:eventToBeRemoved];
        [self deleteSwipedCell:eventToBeRemoved atIndexPath:indexPath withRowAnimation:UITableViewRowAnimationLeft];
    } else if(swipeDirection == UISwipeGestureRecognizerDirectionRight) {
        [completedDataSource completeEvent:eventToBeRemoved];
        [self deleteSwipedCell:eventToBeRemoved atIndexPath:indexPath withRowAnimation:UITableViewRowAnimationRight];
    } else {
        // wait, what
    }
    
    [MemoryDataSource saveAllEvents];
    //[MemoryDataSource saveEventsForDataSource:[listHandler currentListDataSource]];
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
    
    // save events for current data source
    [MemoryDataSource saveEventsForDataSource:[listHandler currentListDataSource]];
    
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
    
    [self completeCreationOfEventWith:textField];
    [textField setEnabled:NO];
    [textField resignFirstResponder];
    keyboardIsUp = NO;
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
    [MemoryDataSource loadAllEvents];
    
    self.containerView.alpha = 0;
    
    // mmmm data
    eventDataSource = [ListEventDataSource sharedDataSource];
    completedDataSource = [CompletedDataSource sharedDataSource];
    deletedDataSource = [DeletedDataSource sharedDataSource];
    listHandler = [CurrentListHandler sharedDataSource];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self UIGestureRecognizersAreFun];
}

- (void)didTapTableView:(UITapGestureRecognizer *)tapRecognizer {
    if(keyboardIsUp) {
        NSLog(@"keyboard is up");

        int numberOfCells = [self.tableView numberOfRowsInSection:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numberOfCells-1 inSection:0];
        ListEventCell *cell = (ListEventCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        [self completeCreationOfEventWith:cell.textField];
        [self insertRowAtBottomOfTableView];
        [self bringUpKeyboardForNewEvent];
        //[self pullUp:nil];
    } else {
        NSLog(@"keyboard is not up");
    }
    
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

- (void)switchCategoryWithDirection:(UISwipeGestureRecognizerDirection)direction andDataSource:(id)dataSource {
    BOOL shouldIncrement;
    UITableViewRowAnimation insertAnimation;
    UITableViewRowAnimation deleteAnimation;
    
    shouldIncrement = direction == UISwipeGestureRecognizerDirectionRight;
    
    // determine which direction to insert/delete
    if(direction == UISwipeGestureRecognizerDirectionLeft) {
        //shouldIncrement = NO;
        deleteAnimation = UITableViewRowAnimationLeft;
        insertAnimation = UITableViewRowAnimationRight;
    } else if(direction == UISwipeGestureRecognizerDirectionRight) {
        //shouldIncrement = YES;
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
    if(shouldIncrement) [dataSource incrementCurrentKey];
    else [dataSource decrementCurrentKey];
    
    // insert rows
    NSArray *arr = [dataSource eventsForCurrentKey];
    NSIndexPath *indexPath;
    for(int i = 0; i < arr.count; ++i) {
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:insertAnimation];
    }
}

- (UITableViewRowAnimation)directionToInsert:(NSNumber *)newList {
    int currentList = [[listHandler currentList] intValue];
    int newListInt = newList.intValue;
    
    return newListInt > currentList ? UITableViewRowAnimationRight : UITableViewRowAnimationLeft;
}

- (UITableViewRowAnimation)directionToDelete:(NSNumber *)newList {
    int currentList = [[listHandler currentList] intValue];
    int newListInt = newList.intValue;
    
    return newListInt > currentList ? UITableViewRowAnimationLeft : UITableViewRowAnimationRight;
}

- (void)completeCreationOfEventWith:(UITextField *)textField {
    ListEvent *newEvent = [eventDataSource recentlyAddedEvent];
    newEvent.title = textField.text;
    [self.tableView reloadData];
    textField.text = @"";
    [textField setEnabled:NO];
    //[MemoryDataSource saveAllEvents];
    [MemoryDataSource saveEventsForDataSource:[listHandler currentListDataSource]];
}

- (void)UIGestureRecognizersAreFun {
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] init];
    [pinchRecognizer addTarget:self action:@selector(pinchedCells:)];
    [self.tableView addGestureRecognizer:pinchRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapRecognizer addTarget:self action:@selector(didTapTableView:)];
    [self.tableView addGestureRecognizer:tapRecognizer];
    
    UISwipeGestureRecognizer *swipeDeletedNavigationLeft = [[UISwipeGestureRecognizer alloc] init];
    [swipeDeletedNavigationLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeDeletedNavigationLeft addTarget:self action:@selector(switchCategory:)];
    [self.deletedImageView addGestureRecognizer:swipeDeletedNavigationLeft];
    
    UISwipeGestureRecognizer *swipeDeletedNavigationRight = [[UISwipeGestureRecognizer alloc] init];
    [swipeDeletedNavigationRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [swipeDeletedNavigationRight addTarget:self action:@selector(switchCategory:)];
    [self.deletedImageView addGestureRecognizer:swipeDeletedNavigationRight];
    
    UITapGestureRecognizer *doubleTapDeleted = [[UITapGestureRecognizer alloc] init];
    [doubleTapDeleted setNumberOfTapsRequired:2];
    [doubleTapDeleted addTarget:self action:@selector(showAllEvents:)];
    [self.deletedImageView addGestureRecognizer:doubleTapDeleted];
    
    UISwipeGestureRecognizer *swipeCompletedNavigationLeft = [[UISwipeGestureRecognizer alloc] init];
    [swipeCompletedNavigationLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeCompletedNavigationLeft addTarget:self action:@selector(switchCategory:)];
    [self.completedImageView addGestureRecognizer:swipeCompletedNavigationLeft];
    
    UISwipeGestureRecognizer *swipeCompletedNavigationRight = [[UISwipeGestureRecognizer alloc] init];
    [swipeCompletedNavigationRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [swipeCompletedNavigationRight addTarget:self action:@selector(switchCategory:)];
    [self.completedImageView addGestureRecognizer:swipeCompletedNavigationRight];
    
    UITapGestureRecognizer *doubleTapCompleted = [[UITapGestureRecognizer alloc] init];
    [doubleTapCompleted setNumberOfTapsRequired:2];
    [doubleTapCompleted addTarget:self action:@selector(showAllEvents:)];
    [self.completedImageView addGestureRecognizer:doubleTapCompleted];
}

@end
