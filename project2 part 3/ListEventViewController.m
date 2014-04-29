//
//  ViewController.m
//  project2 part 3
//
//  Created by Tony Albor on 9/8/13.
//  Copyright (c) 2013 tonyalbor. All rights reserved.
//

#import "ListEventViewController.h"
#import "MemoryDataSource.h"
#import "List.h"
#import "ListSet.h"
#import "ListSetDataSource.h"

@interface ListEventViewController ()

@end

@implementation ListEventViewController

@synthesize listSetDataSource;

static CGFloat cellHeight = 80;

// hmmm, doesn't seem like I'm using this
// TODO :: check to see if i really need this
// will probably delete later
static BOOL isInCreateMode = YES;

static BOOL keyboardIsUp = NO;

#pragma mark UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return _cells.count;
    ListSet *currentSet = [listSetDataSource listSetForCurrentKey];
    self.title = [currentSet title];
    return _cells.count; // or [[currentSet currentList] numberOfEventsForCurrentCategory]
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
    
    ListEvent *event = [_cells objectAtIndex:indexPath.row];
    
    // date still unimplemented
    //[cell.dateLabel setText:event.date];
    [cell.dateLabel setHidden:YES];
    [cell.eventLabel setText:event.title];
    
    if(event.categoryID == nil || [event.categoryID isEqualToNumber:@99]) event.categoryID = @0;
    
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
    
    ListSet *currentSet = [listSetDataSource listSetForCurrentKey];
    for(UIGestureRecognizer *gesture in cell.gestureRecognizers) {
        [gesture setEnabled:[currentSet isInDue]];
    }
}

- (void)insertEvents:(List *)list inDirection:(UITableViewRowAnimation)direction {
    // TODO :: check if this works
    // leave this for reference, delete later
    //NSArray *events = [set isDisplayingAllEvents] ? [ListSet getAllEventsForList:list] : [list objectForKey:[set currentKey]];
    
    NSArray *events = [NSArray arrayWithArray:[list isDisplayingAllEvents] ? [list getAllEvents] : [list eventsForCurrentCategory]];
    
    for(int i = 0; i < events.count; ++i) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:direction];
    }
}

- (void)deleteAllEventsFromTableViewInDirection:(UITableViewRowAnimation)direction {
    for(int i = 0; i < [self.tableView numberOfRowsInSection:0]; ++ i) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:direction];
    }
}

- (void)insertRowAtBottomOfTableView {
    int numberOfRows = (int)[self.tableView numberOfRowsInSection:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numberOfRows inSection:0];
    
    List *list = [[listSetDataSource listSetForCurrentKey] currentList];
    ListEvent *event = [[ListEvent alloc] init];
    
    [self.tableView beginUpdates];
    [list addEvent:event];
    [_cells addObject:event];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    [MemoryDataSource save];
    NSLog(@"inserted new row: %d",numberOfRows);
}

- (void)bringUpKeyboardForNewEvent {
    int newCellIndex = (int)[self.tableView numberOfRowsInSection:0] - 1;
    NSIndexPath *newCellIndexPath = [NSIndexPath indexPathForRow:newCellIndex inSection:0];
    ListEventCell *newCell = (ListEventCell *)[self.tableView cellForRowAtIndexPath:newCellIndexPath];
   
    [newCell.textField setEnabled:YES];
    [newCell.textField becomeFirstResponder];
    [newCell.textField isFirstResponder];
    keyboardIsUp = YES;
}

- (void)deleteSwipedCell:(ListEvent *)event atIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)direction {
    ListSet *currentSet = [listSetDataSource listSetForCurrentKey];
    List *list = [currentSet currentList];
    
    [self.tableView beginUpdates];
    [list removeEvent:event];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:direction];
    [self loadEventsIntoCellsArray];
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

- (List *)listForImageView:(UIImageView *)imageView {
    ListSet *set = [listSetDataSource listSetForCurrentKey];
    if([imageView isEqual:_deletedImageView]) return [set deleted];
    else if([imageView isEqual:_completedImageView]) return [set completed];
    else if([imageView isEqual:_eventsImageView]) return [set due];
    else return nil;
}

- (IBAction)switchCategory:(UISwipeGestureRecognizer *)gestureRecognizer {
    // called when image view is swiped left/right
    UIImageView *imageView = (UIImageView *)gestureRecognizer.view;
    List *list = [self listForImageView:imageView];
    
    // nowhere to switch to
    if([list numberOfEvents] <= 1) return;
    
    // link up the events to the right category key
    [list organizeEvents];
    
    [self.tableView beginUpdates];
    [self switchCategoryWithDirection:gestureRecognizer.direction andList:list];
    [self loadEventsIntoCellsArray];
    [self.tableView endUpdates];
}

- (IBAction)showAllEvents:(id)sender {
    // called when double tapped
    UITapGestureRecognizer *gestureRecognizer = (UITapGestureRecognizer *)sender;
    UIImageView *imageView = (UIImageView *)gestureRecognizer.view;
    List *list = [self listForImageView:imageView];
    
    if([list numberOfEvents] <= 1) return;
    
    if(![list isDisplayingAllEvents]) {
        // TODO :: investigate recentlyadded
        //if(currentSet.recentlyAddedEvent) currentSet.recentlyAddedEvent = nil;
        if(list.recentlyAddedEvent) list.recentlyAddedEvent = nil;
        [self.tableView beginUpdates];
        [self deleteAllEventsFromTableViewInDirection:UITableViewRowAnimationLeft];
        [list organizeEvents];
        [list displayAllEvents];
        
        NSArray *allEvents = [list getAllEvents];
        for(int i = 0; i < allEvents.count; ++i)  {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        }
        [self loadEventsIntoCellsArray];
        [self.tableView endUpdates];
    }
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
    if([[listSetDataSource listSetForCurrentKey] isInDue]) return;
    
    [UIView animateWithDuration:.3 animations:^{
        // big events
        // events (105,468)
        // completed (220,496)
        // deleted (17, 496)
        
        [_eventsImageView setFrame:CGRectMake(105, 468, 110, 100)];
        [_completedImageView setFrame:CGRectMake(220, 496, 80, 72)];
        [_deletedImageView setFrame:CGRectMake(17, 496, 80, 72)];
        
        [_eventsImageView setAlpha:.7];
        [_completedImageView setAlpha:.2];
        [_deletedImageView setAlpha:.2];
    }];
    
    UITableViewRowAnimation insertDirection = [self directionToInsert:@1];
    UITableViewRowAnimation deleteDirection = [self directionToDelete:@1];
    
    ListSet *currentSet = [listSetDataSource listSetForCurrentKey];
    [currentSet setCurrentList:EVENTS_DUE];
    [self.tableView beginUpdates];
    [self deleteAllEventsFromTableViewInDirection:deleteDirection];
    [self insertEvents:currentSet.currentList inDirection:insertDirection];
    [self loadEventsIntoCellsArray];
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
    if([[listSetDataSource listSetForCurrentKey] isInCompleted]) return;
    if([[[listSetDataSource listSetForCurrentKey] completed] isEmpty]) return;
    
    [UIView animateWithDuration:.3 animations:^{
        // big completed
        // events (105,496)
        // completed (190,468)
        // deleted (17,496)
        
        [_eventsImageView setFrame:CGRectMake(105, 496, 80, 72)];
        [_completedImageView setFrame:CGRectMake(190, 468, 110, 100)];
        [_deletedImageView setFrame:CGRectMake(17, 496, 80, 72)];
        
        [_eventsImageView setAlpha:.2];
        [_completedImageView setAlpha:.7];
        [_deletedImageView setAlpha:.2];
    }];
    
    UITableViewRowAnimation insertDirection = [self directionToInsert:@2];
    UITableViewRowAnimation deleteDirection = [self directionToDelete:@2];
    
    // get current set and set the current list to completed
    ListSet *currentSet = [listSetDataSource listSetForCurrentKey];
    [currentSet setCurrentList:EVENTS_COMPLETED];
    
    [self.tableView beginUpdates];
    // delete cells from screen
    [self deleteAllEventsFromTableViewInDirection:deleteDirection];
    // set a current category if none is set
    if(!currentSet.currentList.currentCategory) {
        currentSet.currentList.currentCategory = @0;
        if(![currentSet.currentList eventsForCurrentCategory]) {
            [currentSet.currentList incrementCategory];
        }
    }
    // insert events from current list into model
    [self insertEvents:currentSet.currentList inDirection:insertDirection];
    // insert into cells array
    [self loadEventsIntoCellsArray];
    [self.tableView endUpdates];
}

- (IBAction)didTapDeleted:(id)sender {
    if([[listSetDataSource listSetForCurrentKey] isInDeleted]) return;
    if([[[listSetDataSource listSetForCurrentKey] deleted] isEmpty]) return;
    
    [UIView animateWithDuration:.3 animations:^{
        // big deleted
        // events (132,496)
        // completed (220,496)
        // deleted (20,468)
        
        [_eventsImageView setFrame:CGRectMake(132, 496, 80, 72)];
        [_completedImageView setFrame:CGRectMake(220, 496, 80, 72)];
        [_deletedImageView setFrame:CGRectMake(20, 468, 110, 100)];
        
        [_eventsImageView setAlpha:.2];
        [_completedImageView setAlpha:.2];
        [_deletedImageView setAlpha:.7];
    }];
    
    UITableViewRowAnimation insertDirection = [self directionToInsert:@0];
    UITableViewRowAnimation deleteDirection = [self directionToDelete:@0];

    ListSet *currentSet = [listSetDataSource listSetForCurrentKey];
    [currentSet setCurrentList:EVENTS_DELETED];
    [self.tableView beginUpdates];
    [self deleteAllEventsFromTableViewInDirection:deleteDirection];
    if(!currentSet.currentList.currentCategory) {
        currentSet.currentList.currentCategory = @0;
        if(![currentSet.currentList eventsForCurrentCategory]) {
            [currentSet.currentList incrementCategory];
        }
    }
    [self insertEvents:currentSet.currentList inDirection:insertDirection];
    [self loadEventsIntoCellsArray];
    [self.tableView endUpdates];
    
}


#pragma mark ListEventCell UIGestureRecognizer

- (void)swipedCell:(UISwipeGestureRecognizer *)gestureRecognizer {
    if(![[listSetDataSource listSetForCurrentKey] isInDue]) return;
    
    UISwipeGestureRecognizerDirection swipeDirection = gestureRecognizer.direction;
    ListEventCell *cell = (ListEventCell *)gestureRecognizer.view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ListEvent *eventToBeRemoved = [_cells objectAtIndex:indexPath.row];
    ListSet *currentSet = [listSetDataSource listSetForCurrentKey];
    
    if(swipeDirection == UISwipeGestureRecognizerDirectionLeft) {
        [currentSet deleteEvent:eventToBeRemoved];
        [self deleteSwipedCell:eventToBeRemoved atIndexPath:indexPath withRowAnimation:UITableViewRowAnimationLeft];
    } else if(swipeDirection == UISwipeGestureRecognizerDirectionRight) {
        [currentSet completeEvent:eventToBeRemoved];
        [self deleteSwipedCell:eventToBeRemoved atIndexPath:indexPath withRowAnimation:UITableViewRowAnimationRight];
    } else {
        // wait, what
    }
    
    // TODO :: save
    //[MemoryDataSource saveAllEvents];
}

- (void)tappedCell:(UITapGestureRecognizer *)gestureRecognizer {
    NSLog(@"tapped cell");
    ListEventCell *cell = (ListEventCell *)gestureRecognizer.view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ListEvent *event = [_cells objectAtIndex:indexPath.row];
    
    [event changeColor];
    [self loadEventsIntoCellsArray];
    [self.tableView reloadData];
    
    // TODO :: save events or something
    // save events for current data source
    //[MemoryDataSource saveEventsForDataSource:[listHandler currentListDataSource]];
}

- (void)longPressedCell:(UILongPressGestureRecognizer *)gesutureRecognizer {
    if(gesutureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"got in");
        ListEventCell *cell = (ListEventCell *)gesutureRecognizer.view;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        ListEvent *event = [_cells objectAtIndex:indexPath.row];
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
    // something is calling [MemoryDataSource load] before this gets called
    // and then once this is actually called, it gets called twice
    [super viewDidLoad];
    
    NSLog(@"view did load");
    [MemoryDataSource load];
    //[MemoryDataSource clear];
    
    self.containerView.alpha = 0;
    
    // set up list set data source
    listSetDataSource = [ListSetDataSource sharedDataSource];
    ListSet *listSet = [[ListSet alloc] init];
    
    [listSetDataSource addSet:listSet forKey:@0];
    [listSetDataSource setCurrentKey:@0];
    _cells = [[NSMutableArray alloc] init];
    ListSet *currentSet = [[ListSetDataSource sharedDataSource] listSetForCurrentKey];
    if(!currentSet.currentList.currentCategory) {
        currentSet.currentList.currentCategory = @0;
        if(![currentSet.currentList eventsForCurrentCategory]) {
            //[currentSet.currentList incrementCategory];
        }
    }
    [self loadEventsIntoCellsArray];
    

    
    // Do any additional setup after loading the view, typically from a nib.
    
    [self UIGestureRecognizersAreFun];
    // this method is getting called twice
    // might have to do something with the image views
}

- (void)didTapTableView:(UITapGestureRecognizer *)tapRecognizer {
    if(keyboardIsUp) {
        NSLog(@"keyboard is up");

        int numberOfCells = (int)[self.tableView numberOfRowsInSection:0];
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

- (void)loadEventsIntoCellsArray {
    List *list = [[listSetDataSource listSetForCurrentKey] currentList];
    BOOL allEventsShown = [list isDisplayingAllEvents];
    _cells = [NSMutableArray arrayWithArray:(allEventsShown ? [list getAllEvents] : [list eventsForCurrentCategory])];
}

- (void)switchCategoryWithDirection:(UISwipeGestureRecognizerDirection)direction andList:(List *)list {
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
    int numOfCells = (int)[self.tableView numberOfRowsInSection:0];
    for(int i = 0; i < numOfCells; ++i) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:deleteAnimation];
    }
    
    // increment/decrement key
    if(shouldIncrement) [list incrementCategory];
    else [list decrementCategory];
    
    // insert rows
    NSArray *arr = [list eventsForCurrentCategory];
    NSIndexPath *indexPath;
    for(int i = 0; i < arr.count; ++i) {
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:insertAnimation];
    }
}

- (UITableViewRowAnimation)directionToInsert:(NSNumber *)newList {
    int currentList = [[[listSetDataSource listSetForCurrentKey] _currentList] intValue];
    int newListInt = newList.intValue;
    
    return newListInt > currentList ? UITableViewRowAnimationRight : UITableViewRowAnimationLeft;
}

- (UITableViewRowAnimation)directionToDelete:(NSNumber *)newList {
    int currentList = [[[listSetDataSource listSetForCurrentKey] _currentList] intValue];
    int newListInt = newList.intValue;
    
    return newListInt > currentList ? UITableViewRowAnimationLeft : UITableViewRowAnimationRight;
}

- (void)completeCreationOfEventWith:(UITextField *)textField {
    List *list = [[listSetDataSource listSetForCurrentKey] currentList];
    
    ListEvent *newEvent = [list recentlyAddedEvent];
    newEvent.title = textField.text;
    [self.tableView reloadData];
    textField.text = @"";
    [textField setEnabled:NO];
    [_cells replaceObjectAtIndex:_cells.count-1 withObject:newEvent];
    
    // TODO :: save stuff
    //[MemoryDataSource saveEventsForDataSource:[listHandler currentListDataSource]];
    list.recentlyAddedEvent = nil;
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
