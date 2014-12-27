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
#import <POP/POP.h>

#define TEXTFIELD_NAVIGATION_TITLE_TAG 5

// TODO :: there's a bug with the transition nav centers method calls
// they're just not being called at the right time

// TODO :: canceling animations
// an animation might not be complete while another animation on the same object
// is beginning. this leads to some weird UI

@interface ListEventViewController () {
    WYPopoverController *popover;
}

@end

@implementation ListEventViewController {
    CGFloat _currentScale;
    CGFloat _lastScale;
    CGPoint _originalCenter;
    CGPoint _originalPoint;
    BOOL _goToNextSetOnRelease;
    BOOL _goToPreviousSetOnRelease;
}

// TODO :: FEATURE ::
// include a count above the trash and completed icon
// that will let the user know that there is now something there
// after they complete/delete an event

@synthesize listSetDataSource;

static CGFloat cellHeight = 12;

// hmmm, doesn't seem like I'm using this
// TODO :: check to see if i really need this
// will probably delete later
static BOOL isInCreateMode = YES;

// TODO :: figure out how to completely delete this
// i might already be able to
// edit :: actually, not yet. check didTapTableView:
static BOOL keyboardIsUp = NO;

static BOOL _isCreatingNewCell = NO;

// set to YES when a cell color changes, or when reordering of cells occurs
static BOOL shouldUpdateSortIds = NO;

#pragma mark UITableViewDataSource

- (void)setUpHeaderView {
    
    //NSLog(@"VIEWFORHEADERINSECTION");
    
    // create slim section header view to display list set info (eg. title, #events, ...)
	
	UIView *_header = nil;
    
	if(_header) {
		NSLog(@"no header");
		ListSet *currentSet = [listSetDataSource listSetForCurrentKey];
    
		_header = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.tableView.frame.size.width, 30)];
	
		UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:_header.frame];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, _header.frame.size.width, 25)];
		[label setTextColor:[UIColor blackColor]];
				[label setText:[[currentSet title] uppercaseString]];
		[label setTag:30];
		
		//UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:[[currentSet title] uppercaseString]];
		[navigationBar setTranslucent:YES];
		[navigationBar setAlpha:0.8];
		//[navigationBar setItems:@[item]];
	
		[_header addSubview:navigationBar];
    
		[_header addSubview:label];
		
		//[self.view addSubview:_header];
	} else {
		_header = [[UIView alloc] init];
		[_header setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
		[_header setAlpha:0.5];
		[_header setBackgroundColor:[UIColor blackColor]];
//		[self.view addSubview:_header];
		
		ListSet *currentSet = [listSetDataSource listSetForCurrentKey];
		NSString *setTitle = [[currentSet title] lowercaseString];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 45)];
		
		[label setText:setTitle];
		
		[label addSubview:_header];
		
		[label setAlpha:0.7];
		
		[self.view addSubview:label];
		[label setTag:30];
		
		NSLog(@"yes header");
	}
}

- (void)updateListSetHeader {
	UILabel *label = (UILabel *)[self.view viewWithTag:30];
	if(label) {
		[label setText:[[[listSetDataSource listSetForCurrentKey] title] lowercaseString]];
	} else {
		NSLog(@"no label");
	}
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [ListEventCell selectedIndex] == indexPath.row ? /*cellHeight + 250*/self.view.frame.size.height : /*cellHeight*/UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    //[self tableView:tableView viewForHeaderInSection:0];
    /*
    UIView *headerView = [self tableView:tableView viewForHeaderInSection:0];
    if(headerView != nil) {
        NSLog(@"header view exists");
        ListSet *currentSet = [listSetDataSource listSetForCurrentKey];
        UILabel *label = (UILabel *)[self.view viewWithTag:19];
		
        [label setText:[currentSet.title uppercaseString]];
        
        // TODO :: work on modifying existing label from header view
        
    } else {
        NSLog(@"header view does not exist");
    }
    */
    
    //ListSet *currentSet = [listSetDataSource listSetForCurrentKey];
    //[self.titleTextField setText:[[currentSet title] uppercaseString]];
    return [[[listSetDataSource listSetForCurrentKey] currentList] numberOfEventsForCurrentCategory];
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
    cell.delegate = self;
    ListEvent *event = [listSetDataSource eventAtIndex:indexPath.row];
    
    // date still unimplemented
    //[cell.dateLabel setText:event.date];
    [cell.dateLabel setHidden:YES];
    [cell.eventLabel setText:event.title];
    [cell setExpanded:[ListEventCell selectedIndex] == indexPath.row];
    
    if(event.categoryID == nil || [event.categoryID isEqualToNumber:@99] /*|| ![CustomCellColor colorExistsForCategoryId:event.categoryID]*/) event.categoryID = @0;
    
    CustomCellColor *backgroundColor = [CustomCellColor colorForId:[event.categoryID isEqualToNumber:@99] ? @0 : event.categoryID];
    cell.backgroundColor = [backgroundColor customCellColorToUIColor];
    
    [cell.textField setTag:indexPath.row];
    
    if(cell.gestureRecognizers.count != 3) {
        // 3 is the number of recognizers I'd like to add
        // if there are 3 recognizers for the cell, then there
        // is no need to add them again
        // (since this method gets called a lotttt)
        [cell initWithGestureRecognizers];
    }
    
    ListSet *currentSet = [listSetDataSource listSetForCurrentKey];
    for(UIGestureRecognizer *gesture in cell.gestureRecognizers) {
        [gesture setEnabled:[currentSet isInDue] || [gesture isKindOfClass:[UIPanGestureRecognizer class]]];
    }
}

- (void)insertEvents:(List *)list inDirection:(UITableViewRowAnimation)direction {
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
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    //[MemoryDataSource save];
    NSLog(@"inserted new row: %d",numberOfRows);
}

- (BOOL)isCreatingNewCell {
    return _isCreatingNewCell;
}

- (void)bringUpKeyboardForNewEvent {
    int newCellIndex = (int)[self.tableView numberOfRowsInSection:0] - 1;
    NSIndexPath *newCellIndexPath = [NSIndexPath indexPathForRow:newCellIndex inSection:0];
    ListEventCell *newCell = (ListEventCell *)[self.tableView cellForRowAtIndexPath:newCellIndexPath];
    
    [newCell.textField setUserInteractionEnabled:YES];
    [newCell.textField setEnabled:YES];
    [newCell.textField becomeFirstResponder];
    
    keyboardIsUp = YES;
    
    [self enableTableViewTap];
    
    for(UIGestureRecognizer *gestureRecognizer in self.tableView.gestureRecognizers) {
        if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            //[gestureRecognizer setEnabled:YES];
        } else if([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
            // pinch for table view cell size adjustment
            [gestureRecognizer setEnabled:NO];
        } else if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            // pan the entire table view out; not allowed
            [gestureRecognizer setEnabled:NO];
        }
    }
}

// TODO :: deleting _right_ after creating cell causes crash
- (void)deleteSwipedCell:(ListEvent *)event atIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)direction {
    ListSet *currentSet = [listSetDataSource listSetForCurrentKey];
    List *list = [currentSet currentList];
    [list removeEvent:event];
    id cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    [cell swipeOffScreenInDirection:direction atIndexPath:indexPath];
}

- (void)didFinishMovingCellOffScreenAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

#pragma mark UITableView Adjustments

- (void)scrollToBottomOfTableView {
    int numberOfEvents = [[[listSetDataSource listSetForCurrentKey] currentList] numberOfEventsForCurrentCategory];
    if(numberOfEvents > 3) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numberOfEvents-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)adjustTableViewForInsertion {
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 240, 0);
    [UIView animateWithDuration:0.3 animations:^{
        [self.tableView setContentInset:insets];
        [self.tableView setScrollIndicatorInsets:insets];
    }];
}

- (void)readjustTableViewBackToNormal {
    [UIView animateWithDuration:0.3 animations:^{
        [self.tableView setContentInset:UIEdgeInsetsZero];
        [self.tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    }];
}

#pragma mark UIGestureRecognizer Events

- (IBAction)pullUp:(id)sender {
    if(!isInCreateMode) return;
    _isCreatingNewCell = YES;
    [self adjustTableViewForInsertion];
    [self scrollToBottomOfTableView];
    [self insertRowAtBottomOfTableView];
    [self bringUpKeyboardForNewEvent];
}

- (List *)listForImageView:(UIView *)imageView {
    ListSet *set = [listSetDataSource listSetForCurrentKey];
    if([imageView isEqual:_deletedImageView]) return [set deleted];
    else if([imageView isEqual:_completedImageView]) return [set completed];
    else if([imageView isEqual:_eventsImageView]) return [set due];
    else return nil;
}

- (IBAction)switchCategory:(UISwipeGestureRecognizer *)gestureRecognizer {
    // called when nav center image view is swiped left/right
    
    UIView *imageView = (UIView *)gestureRecognizer.view;
    UISwipeGestureRecognizerDirection swipeDirection = gestureRecognizer.direction;
    
    List *list = [self listForImageView:imageView];
    
    // nowhere to switch to
    if([list numberOfEvents] <= 1) return;
    
    // link up the events to the right category key
    [list organizeEvents];
    
    // update sort ids
    if(shouldUpdateSortIds) [list updateSortIds];
    shouldUpdateSortIds = NO;
    
    [self.tableView beginUpdates];
    [self switchCategoryWithDirection:swipeDirection andList:list];
    [self.tableView endUpdates];
    
    // animate
    UIColor *color = nil;
    if([[list currentCategory] isEqualToNumber:@99]) {
        color = [UIColor lightGrayColor];
    } else {
//        color = [[CustomCellColor colorForId:list.currentCategory] customCellColorToUIColor];
        color = [[CustomCellColor darkColorForId:list.currentCategory] customCellColorToUIColor];
    }
    [UIView animateWithDuration:0.2 animations:^{
        [imageView setBackgroundColor:color];
    }];
    
    
//    
//    CustomCellColor *backgroundColor = [CustomCellColor colorForId:[event.categoryID isEqualToNumber:@99] ? @0 : event.categoryID];
//    cell.backgroundColor = [backgroundColor customCellColorToUIColor];
}

- (IBAction)showAllEvents:(id)sender {
    // called when double tapped
    UITapGestureRecognizer *gestureRecognizer = (UITapGestureRecognizer *)sender;
    UIImageView *imageView = (UIImageView *)gestureRecognizer.view;
    List *list = [self listForImageView:imageView];
    
    if(![[imageView backgroundColor] isEqual:[UIColor lightGrayColor]]) {
        [UIView animateWithDuration:0.25 animations:^{
            [imageView setBackgroundColor:[UIColor lightGrayColor]];
        }];
    }
    
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
        [self.tableView endUpdates];
    }
    [MemoryDataSource save];
}

- (IBAction)showMenu:(UILongPressGestureRecognizer *)sender {
    
    // TODO :: change the minumum press duration for long press recognizer
    // needs to be a little faster
    
    if(sender.state == UIGestureRecognizerStateBegan) {
        UIImageView *imageView = (UIImageView *)sender.view;
        MenuViewController *contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menu"];
        
        // TODO :: don't know if i should do this here in appearance,
        // or if i should just modify the theme like below
        WYPopoverBackgroundView *appearance = [WYPopoverBackgroundView appearance];
        [appearance setOverlayColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.4]];
        [appearance setFillBottomColor:[UIColor whiteColor]];
//        [appearance setFillTopColor:[UIColor blackColor]];
//        [appearance setOuterStrokeColor:[UIColor blackColor]];
//        [appearance setInnerStrokeColor:[UIColor blackColor]];
        [appearance setBorderWidth:5];
        
        popover = [[WYPopoverController alloc] initWithContentViewController:contentViewController];
        [contentViewController setDelegate:self];
        popover.delegate = self;
        popover.passthroughViews = @[imageView];
        popover.wantsDefaultContentAppearance = NO;
        popover.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
        
        //popover.theme.overlayColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.40];
        //popover.theme.fillBottomColor = [UIColor whiteColor];
    
        
        [popover presentPopoverFromRect:imageView.frame
                                 inView:self.view
               permittedArrowDirections:WYPopoverArrowDirectionAny
                               animated:YES
                                options:WYPopoverAnimationOptionScale];
        
         
         
        /*
        [popover presentPopoverFromRect:imageView.frame
                                 inView:self.view
               permittedArrowDirections:WYPopoverArrowDirectionAny
                               animated:NO completion:^ {
                                   
                               }
         ];
         
        
        POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
      //anim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 400, 400)];
        anim.toValue = [NSValue valueWithCGRect:popover.contentViewController.view.frame];
        [anim.toValue setObject:[NSObject new] forKey:@"objectKey"];
        
        [popover.contentViewController.view pop_addAnimation:anim forKey:@"size"];
         
        
         */
        
    } else if(sender.state == UIGestureRecognizerStateChanged) {
        NSLog(@"changing");
    } else if(sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"ended");
    }
}

- (IBAction)didTapEvents:(id)sender {
    //[self showNavCenters];
    if([popover isPopoverVisible]) [popover dismissPopoverAnimated:YES];
    if([[listSetDataSource listSetForCurrentKey] isInDue]) return;
    
    [self animateDueBig];
    
    UITableViewRowAnimation insertDirection = [self directionToInsert:@1];
    UITableViewRowAnimation deleteDirection = [self directionToDelete:@1];
    
    ListSet *currentSet = [listSetDataSource listSetForCurrentKey];
    [currentSet setCurrentList:EVENTS_DUE];
    [self.tableView beginUpdates];
    [self deleteAllEventsFromTableViewInDirection:deleteDirection];
    [self insertEvents:currentSet.currentList inDirection:insertDirection];
    [self.tableView endUpdates];
}

- (void)animateCompletedBig {
    CGRect due = CGRectMake(105, 486, 80, 80);
    CGRect com = CGRectMake(190, 455, 110, 110);
    CGRect del = CGRectMake(17, 486, 80, 80);
    [self animateCompletedWithRect:com dueWithRect:due deletedWithRect:del biggest:EVENTS_COMPLETED];
}

- (void)animateDueBig {
    CGRect due = CGRectMake(105, 455, 110, 110);
    CGRect com = CGRectMake(220, 486, 80, 80);
    CGRect del = CGRectMake(17, 486, 80, 80);
    [self animateCompletedWithRect:com dueWithRect:due deletedWithRect:del biggest:EVENTS_DUE];
}

- (void)animateDeletedBig {
    CGRect due = CGRectMake(132, 486, 80, 80);
    CGRect com = CGRectMake(220, 486, 80, 80);
    CGRect del = CGRectMake(20, 455, 110, 110);
    [self animateCompletedWithRect:com dueWithRect:due deletedWithRect:del biggest:EVENTS_DELETED];
}

// TODO :: possibly make an 'animations' class
// cuz this is gonna get messy
- (void)animateCompletedWithRect:(CGRect)completedRect dueWithRect:(CGRect)dueRect deletedWithRect:(CGRect)deletedRect biggest:(NSNumber *)biggest {
    
    POPSpringAnimation *dueCornerRadius = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerCornerRadius];
    POPSpringAnimation *completedCornerRadius = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerCornerRadius];
    POPSpringAnimation *deletedCorderRadius = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerCornerRadius];
    
    dueCornerRadius.springBounciness = 15;
    dueCornerRadius.springSpeed = 8;
    dueCornerRadius.toValue = @(dueRect.size.height/2);
    
    completedCornerRadius.springBounciness = 15;
    completedCornerRadius.springSpeed = 8;
    completedCornerRadius.toValue = @(completedRect.size.height/2);
    
    deletedCorderRadius.springBounciness = 15;
    deletedCorderRadius.springSpeed = 8;
    deletedCorderRadius.toValue = @(deletedRect.size.height/2);
    
    [[_eventsImageView layer] pop_addAnimation:dueCornerRadius forKey:@"events_corner_radius"];
    [[_completedImageView layer] pop_addAnimation:completedCornerRadius forKey:@"completed_corner_radius"];
    [[_deletedImageView layer] pop_addAnimation:deletedCorderRadius forKey:@"deleted_corner_radius"];
    
    POPSpringAnimation *dueSpring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    dueSpring.toValue = [NSValue valueWithCGRect:dueRect];
    dueSpring.springBounciness = 15;
    dueSpring.springSpeed = 10;
    
    POPSpringAnimation *completedSpring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    completedSpring.toValue = [NSValue valueWithCGRect:completedRect];
    completedSpring.springBounciness = 15;
    completedSpring.springSpeed = 10;
    
    POPSpringAnimation *deletedSpring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    deletedSpring.toValue = [NSValue valueWithCGRect:deletedRect];
    deletedSpring.springBounciness = 15;
    deletedSpring.springSpeed = 10;
    
    [_eventsImageView pop_addAnimation:dueSpring forKey:@"events"];
    [_completedImageView pop_addAnimation:completedSpring forKey:@"completed"];
    [_deletedImageView pop_addAnimation:deletedSpring forKey:@"deleted"];
    
    POPBasicAnimation *dueFade = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    POPBasicAnimation *completedFade = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    POPBasicAnimation *deletedFade = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    
    dueFade.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    completedFade.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    deletedFade.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    dueFade.fromValue = @(_eventsImageView.alpha);
    completedFade.fromValue = @(_completedImageView.alpha);
    deletedFade.fromValue = @(_deletedImageView.alpha);
    
    int big = biggest.intValue;
    
    CGFloat active = 0.7;
    CGFloat inactive = 0.3;
    
    if(big == 0) {
        dueFade.toValue = @(inactive);
        completedFade.toValue = @(inactive);
        deletedFade.toValue = @(active);
    } else if(big == 1) {
        dueFade.toValue = @(active);
        completedFade.toValue = @(inactive);
        deletedFade.toValue = @(inactive);
    } else if(big == 2) {
        dueFade.toValue = @(inactive);
        completedFade.toValue = @(active);
        deletedFade.toValue = @(inactive);
    }
    
    [_eventsImageView pop_addAnimation:dueFade forKey:@"dueFade"];
    [_completedImageView pop_addAnimation:completedFade forKey:@"completedFade"];
    [_deletedImageView pop_addAnimation:deletedFade forKey:@"deletedFade"];
}

#pragma mark MenuViewControllerDelegate

- (void)didSelectAddSet {
    [self addListSet];
    [popover dismissPopoverAnimated:YES];
    [self.tableView beginUpdates];
    [self deleteAllEventsFromTableViewInDirection:UITableViewRowAnimationLeft];
    [listSetDataSource setCurrentKey:[listSetDataSource recentlyAddedSet]];
    List *listToInsert = [[listSetDataSource listSetForCurrentKey] currentList];
    [self insertEvents:listToInsert inDirection:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
}

- (void)didSelectListSetAtIndexPath:(NSIndexPath *)indexPath {
    [popover dismissPopoverAnimated:YES options:WYPopoverAnimationOptionScale completion:^{
        NSLog(@"done");
        [self.tableView beginUpdates];
        
        [self deleteAllEventsFromTableViewInDirection:UITableViewRowAnimationLeft];
        [listSetDataSource setCurrentKey:@(indexPath.row)];
        
        List *listToInsert = [[listSetDataSource listSetForCurrentKey] currentList];
        [self insertEvents:listToInsert inDirection:UITableViewRowAnimationRight];
        [self.tableView endUpdates];
        
        [self transitionNavCenters];
    }];
}

#pragma mark Menu Options

- (IBAction)hitButton:(id)sender {
    NSLog(@"hit");
}

#pragma mark UIGestureRecongnizer Deleted

- (void)showNavCenters {
    int currentList = [[[listSetDataSource listSetForCurrentKey] _currentList] intValue];
    switch (currentList) {
        case 0: {
            break;
        }
        case 1: {
            
            [UIView animateWithDuration:0.2 animations:^{
                [_eventsImageView setFrame:CGRectMake(105, 468, 110, 100)];
                [_completedImageView setFrame:CGRectMake(220, 496, 80, 72)];
                [_deletedImageView setFrame:CGRectMake(17, 496, 80, 72)];

            }];
            
            break;
        }
        case 2: {
            break;
        }
            
        default:
            break;
    }
}

- (void)hideNavCenters {
    int currentList = [[[listSetDataSource listSetForCurrentKey] _currentList] intValue];
    switch (currentList) {
            // deleted
        case 0: {
            break;
        }
            //due
        case 1: {
            [UIView animateWithDuration:0.2 animations:^{
                CGPoint originalCenterDeleted = self.deletedImageView.center;
                CGPoint originalCenterCompleted = self.completedImageView.center;
                [self.deletedImageView setCenter:CGPointMake(self.view.frame.size.width / 3, originalCenterDeleted.y)];
                [self.completedImageView setCenter:CGPointMake(self.view.frame.size.width *2/3, originalCenterCompleted.y)];
            }];
            break;
        }
            //completed
        case 2: {
            break;
        }
            
        default:
            break;
    }
}

- (IBAction)didTapCompleted:(id)sender {
    if([[listSetDataSource listSetForCurrentKey] isInCompleted]) return;
    if([[[listSetDataSource listSetForCurrentKey] completed] isEmpty]) return;
    
    [self animateCompletedBig];
    
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
    [self.tableView endUpdates];
}

- (IBAction)didTapDeleted:(id)sender {
    if([[listSetDataSource listSetForCurrentKey] isInDeleted]) return;
    if([[[listSetDataSource listSetForCurrentKey] deleted] isEmpty]) return;
    
    [self animateDeletedBig];
    
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
    [self.tableView endUpdates];
    
}

#pragma mark ListEventCellDelegate

// TODO :: overlay
// top&bottom overlay needs like a few more points in height
// (might be status bar height?)

// TODO :: overlay
// need to add bottom overlay (overlay beneath cell)

// TODO :: make this private variables (not static)
// fuck static
static UIView *_overlay = nil;
static UIView *_bottomOverlay = nil;

- (void)didBeginPanningCell:(ListEventCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    CGRect cellFrame = [self.tableView rectForRowAtIndexPath:indexPath];
    cellFrame.origin.y -= self.tableView.contentOffset.y;
    cellFrame.origin.y += [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    _overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, cellFrame.origin.y)];
    [_overlay setBackgroundColor:[UIColor blackColor]];
    [_overlay setAlpha:0.0];
    
    _bottomOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, cellFrame.origin.y+cellFrame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [_bottomOverlay setBackgroundColor:[UIColor blackColor]];
    [_bottomOverlay setAlpha:0.0];
    
    [self.view addSubview:_overlay];
    [self.view addSubview:_bottomOverlay];
    
    [UIView animateWithDuration:0.2 animations:^{
        [_overlay setAlpha:0.25];
        [_bottomOverlay setAlpha:0.25];
    }];
}

- (void)_removeCellPanningOverlay {
    
    
    [UIView animateWithDuration:0.2 animations:^{
        [_overlay setAlpha:0.0];
        [_bottomOverlay setAlpha:0.0];
        
    } completion:^(BOOL finished) {
        
        if(finished) {
            [_overlay removeFromSuperview];
            [_bottomOverlay removeFromSuperview];
        }
    }];
}

- (void)didStopPanningCell:(ListEventCell *)cell {
    
    [self _removeCellPanningOverlay];
}

- (void)cellPanned:(UIPanGestureRecognizer *)gestureRecognizer complete:(BOOL)shouldComplete delete:(BOOL)shouldDelete {
    
    [self _removeCellPanningOverlay];
	
    ListEventCell *cell = (ListEventCell *)gestureRecognizer.view;
    // TODO :: create cell delegate methods =>
    // didBeginPanningCell:(cell *)cell
    // didStopPanningCell:(cell *)cell
    // (this method is when panning completes)
    //
    // OKAY THIS MIGHT BE DONE NOW
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ListEvent *eventToBeRemoved = [listSetDataSource eventAtIndex:indexPath.row];
    ListSet *currentSet = [listSetDataSource listSetForCurrentKey];
    
    BOOL inDeleted = [[listSetDataSource listSetForCurrentKey] isInDeleted];
    BOOL inDue = [[listSetDataSource listSetForCurrentKey] isInDue];
    BOOL inCompleted = [[listSetDataSource listSetForCurrentKey] isInCompleted];
    
    if( (inDeleted && shouldComplete) || (inCompleted && shouldDelete) ) {
        [currentSet dueEvent:eventToBeRemoved];
    } else if(inDue && shouldDelete) {
        [currentSet deleteEvent:eventToBeRemoved];
    } else if(inDue && shouldComplete) {
        [currentSet completeEvent:eventToBeRemoved];
    }

    UITableViewRowAnimation deleteDirection = shouldDelete ? UITableViewRowAnimationLeft:UITableViewRowAnimationRight;
    [self deleteSwipedCell:eventToBeRemoved atIndexPath:indexPath withRowAnimation:deleteDirection];
}

- (void)changeCellColor:(ListEventCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ListEvent *event = [listSetDataSource eventAtIndex:indexPath.row];
    [event changeColor];
    shouldUpdateSortIds = YES;
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)expandCell:(ListEventCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [ListEventCell setSelectedIndex:indexPath.row];
    [self.tableView beginUpdates];
    [cell addSubviews];
    [self.tableView endUpdates];
    [cell setExpanded:YES];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self animateHideNavs];
    
    // table should not scroll while cell is expanded
    [self.tableView setScrollEnabled:NO];
    
    // disable cell pan
    [[cell panGestureRecognizer] setEnabled:NO];
}

- (void)collapseCell:(ListEventCell *)cell {
    [ListEventCell setSelectedIndex:-1];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [cell setExpanded:NO];
    [cell removeSubviews];
    [self animateShowNavs];
    [self.tableView setScrollEnabled:YES];
    [[cell panGestureRecognizer] setEnabled:YES];
    
}

- (void)collapseCellAtIndex:(int)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [ListEventCell setSelectedIndex:-1];
    ListEventCell *cell = (ListEventCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [cell setExpanded:NO];
    [cell removeSubviews];
}

- (void)cellLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"got in");
        ListEventCell *cell = (ListEventCell *)gestureRecognizer.view;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        ListEvent *event = [listSetDataSource eventAtIndex:indexPath.row];
        CustomCellColor *color = [CustomCellColor colorForId:event.categoryID];
        UIColor *colorcolor = [color customCellColorToUIColor];
        [DetailViewController setColor:colorcolor];
        DetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
        [self.navigationController pushViewController:detail animated:YES];
    }
}

#pragma mark UIScrollViewDelegate

// save CGPoint of long touch
// then on collapse, scroll back to that point

static BOOL navsHidden = NO;

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if(navsHidden) return; // no point in hiding them again if they are already hidden
    
    // okay good
    // TODO :: hide navs if navs are in the way of the last index path
    
    CGFloat currentNavHeight = 0.0;
    
    int n = [[[listSetDataSource listSetForCurrentKey] _currentList] intValue];
    switch(n) {
        case 0: // del
            currentNavHeight += [_deletedImageView frame].size.height;
            break;
        case 1: // event
            currentNavHeight += [_eventsImageView frame].size.height;
            break;
        case 2: // com
            currentNavHeight += [_completedImageView frame].size.height;
            break;
            default:
            break;
    }
    
    if(scrollView.contentSize.height > self.view.frame.size.height - currentNavHeight) {
        [self animateHideNavs];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
//    if(scrollView.contentSize.height < self.view.frame.size.height) return;
    
    if(navsHidden) {
        
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0]-1 inSection:0];
        
        NSArray *visible = [self.tableView indexPathsForVisibleRows];
        for(NSIndexPath *i in visible) {
            if(lastIndexPath.row == i.row) {
                return;
            }
        }
        [self animateShowNavs];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
//    if(scrollView.contentSize.height < self.view.frame.size.height) return;
    
    if(!decelerate && navsHidden) {
        
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0]-1 inSection:0];
        
        NSArray *visible = [self.tableView indexPathsForVisibleRows];
        for(NSIndexPath *i in visible) {
            if(lastIndexPath.row == i.row) {
                return;
            }
        }
        [self animateShowNavs];
    }
}

// TODO :: its a little funnky with lists that are barely larger than table view size
/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"scrolling....");
    if(self.tableView.frame.size.height - scrollView.contentSize.height > 100) {
        return;
    }
    
    if(navsHidden && scrollView.contentSize.height - scrollView.contentOffset.y < 50) {
        
    }
    NSLog(@"scroll view content y look here: %f",scrollView.contentOffset.y);
    NSLog(@"scroll content view entrire heright: %f",scrollView.contentSize.height);
//    NSLog(@"table: %f",self.tableView.frame.size.height);
    NSLog(@"other lat importhant thin g llook her: %f",scrollView.frame.size.height);
    CGFloat scrollViewHeight = self.tableView.frame.size.height > scrollView.contentSize.height ? self.tableView.frame.size.height : scrollView.contentSize.height;

    
    
    if(scrollView.contentOffset.y + scrollView.frame.size.height >= scrollViewHeight-100) {
        // get frames
        if(!navsHidden) {
            [self animateHideNavs];
        }
//        NSLog(@"at the bottom");
    } else {
        if(navsHidden) {
            [self animateShowNavs];
            
//            [UIView animateWithDuration:0.6 animations:^{
//                [_completedImageView setFrame:CGRectOffset(_completedImageView.frame, 0, -_completedImageView.frame.size.height -50)];
//                [_eventsImageView setFrame:CGRectOffset(_eventsImageView.frame, 0, -_eventsImageView.frame.size.height -50)];
//                [_deletedImageView setFrame:CGRectOffset(_deletedImageView.frame, 0, -_deletedImageView.frame.size.height-50)];
//            } completion:^(BOOL finished) {
//                if(finished) {
//                    navsHidden = NO;
//                }
//            }];
//            
//            
//            
//            navsHidden = NO;
        }
    }
}
*/
- (void)animateHideNavs {
    
    NSLog(@"animate hide");
    [self cancelNavAnimations];
    CGRect eventsFrame = CGRectOffset(_eventsImageView.frame, 0, _eventsImageView.frame.size.height+ 50);
    CGRect deletedFrame = CGRectOffset(_deletedImageView.frame, 0, _deletedImageView.frame.size.height+ 50);
    CGRect completedFrame = CGRectOffset(_completedImageView.frame, 0, _completedImageView.frame.size.height+ 50);
    navsHidden = YES;
    [UIView animateWithDuration:0.5 animations:^{
        [_eventsImageView setFrame:eventsFrame];
        [_deletedImageView setFrame:deletedFrame];
        [_completedImageView setFrame:completedFrame];
    } completion:^(BOOL finished) {
        if(finished) {
            navsHidden = YES;
        }
    }];
}

- (void)animateShowNavs {
    
    [self cancelNavAnimations];
    [self transitionNavCenters]; // TODO :: remake this shit to not be so bouncy
    // but only for this function
    // cuz for transitionNavCenters the bounce is just right
    // its just too much for when scrolling ends
    navsHidden = NO;
    NSLog(@"animate show");
    
//    POPSpringAnimation *dueSpring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
//    POPSpringAnimation *completedSpring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
//    POPSpringAnimation *deletedSpring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
//    
//    dueSpring.toValue = [NSValue valueWithCGRect:CGRectOffset(_eventsImageView.frame, 0, -_eventsImageView.frame.size.height-50)];
//    completedSpring.toValue = [NSValue valueWithCGRect:CGRectOffset(_completedImageView.frame, 0, -_completedImageView.frame.size.height-50)];
//    deletedSpring.toValue = [NSValue valueWithCGRect:CGRectOffset(_deletedImageView.frame, 0, -_deletedImageView.frame.size.height-50)];
//    
//    dueSpring.springBounciness = 8;
//    completedSpring.springBounciness = 8;
//    deletedSpring.springBounciness = 8;
//    
//    dueSpring.springSpeed = 4;
//    completedSpring.springSpeed = 5;
//    deletedSpring.springSpeed = 3;
//    
//    [_eventsImageView pop_addAnimation:dueSpring forKey:@"showEventsSpring"];
//    [_completedImageView pop_addAnimation:completedSpring forKey:@"showCompletedSpring"];
//    [_deletedImageView pop_addAnimation:deletedSpring forKey:@"showDeletedSpring"];
//    
//    navsHidden = NO;
}

- (void)cancelNavAnimations {
    
    [_eventsImageView pop_removeAllAnimations];
    [_completedImageView pop_removeAllAnimations];
    [_deletedImageView pop_removeAllAnimations];
}

#pragma mark ListEventCell UIGestureRecognizer

- (void)pinchedCells:(UIPinchGestureRecognizer *)gestureRecongnizer {

    // TODO :: make increase/decrease functions better
    // since I'm going with self sizing cells,
    // i am now attempting to change the constraint values on the cells (top & bottom)
    // its a bit funky so i will just not do anything for now until i get a chance to revisit
    return;
    
    
    
    UIGestureRecognizerState pinchState = gestureRecongnizer.state;
    
    
    if(pinchState == UIGestureRecognizerStateBegan) {
        NSLog(@"pinch began");
        
    } else if(pinchState == UIGestureRecognizerStateChanged) {
        // this is where it all should happen
        
        if(gestureRecongnizer.scale >= _lastScale) {
            // make cells larger
            [self increaseCellSize];
            
        } else if(gestureRecongnizer.scale < _lastScale) {
            // make cells smaller
            [self decreaseCellSize];
        }
        
        _lastScale = gestureRecongnizer.scale;
        [self.tableView reloadData];
        
    } else if(pinchState == UIGestureRecognizerStateRecognized) {
        
        _lastScale = 1.0;
    }
}

- (void)decreaseCellSize {
    if(cellHeight >= 13) {
//		if(cellHeight == 80) {
//			NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
//			for(NSIndexPath *indexPath in indexPaths) {
//				ListEventCell *cell = (ListEventCell *)[self.tableView cellForRowAtIndexPath:indexPath];
//				[cell removeSubviews];
//			}
//		}
        NSInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
        for(int i = 0; i < numberOfRows; ++i) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            ListEventCell *cell = (ListEventCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            cell.topConstraint.constant -= 0.5;
            cell.bottomConstraint.constant -= 0.5;
            cellHeight = cell.bottomConstraint.constant;
        }
//        cellHeight -= 1.0;
    }
}

- (void)increaseCellSize {
    if(cellHeight <= 110) {
//		if(cellHeight == 80) {
//			NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
//			for(NSIndexPath *indexPath in indexPaths) {
//				ListEventCell *cell = (ListEventCell *)[self.tableView cellForRowAtIndexPath:indexPath];
//				[cell addSubviews];
//			}
//		}
        NSInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
        for(int i = 0; i < numberOfRows; ++i) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            ListEventCell *cell = (ListEventCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            cell.topConstraint.constant += 0.5;
            cell.bottomConstraint.constant += 0.5;
            cellHeight = cell.bottomConstraint.constant;
        }
//        cellHeight += 1.0;
    }
}

/*
 
 these two methods need to be changed
 i believe the problem is that the scale
 is based off of the initial two points
 where the pinch started
 
 */
- (BOOL)didPinchInwards:(CGFloat)pinchRecognizer {
    //_currentScale += pinchRecognizer.scale - _lastScale;
    //_lastScale = pinchRecognizer.scale;
    return pinchRecognizer < 1;
}

- (BOOL)didPinchOutwards:(CGFloat)pinchRecognizer {
    return pinchRecognizer > 1;
}

#pragma mark UITextFieldDelegate
// TODO :: this needs to be in listeventcell for finishing the creation of a cell
// still need method here though for nav title textfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    // the nav title textfield tag is 5
    /*
    if(textField.tag == TEXTFIELD_NAVIGATION_TITLE_TAG) {
        [textField resignFirstResponder];
        [[listSetDataSource listSetForCurrentKey] setTitle:textField.text];
        [self.tableView reloadData];
        NSLog(@"text field should return for nav title");
        return NO;
    }
     */
    
    [self readjustTableViewBackToNormal];
    [self scrollToBottomOfTableView];
    [self completeCreationOfEventWith:textField];

    [textField resignFirstResponder];
    [textField setEnabled:NO];

    keyboardIsUp = NO;
    _isCreatingNewCell = NO;
    
    [self disableTableViewTap];
    
    for(UIGestureRecognizer *gestureRecognizer in self.tableView.gestureRecognizers) {
        if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            //[gestureRecognizer setEnabled:NO];
        } else if([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
            // cell sizes
            [gestureRecognizer setEnabled:YES];
        } else if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            // pan the entire table view
            [gestureRecognizer setEnabled:YES];
        }
    }
    [self.tableView reloadData];
    
    // change the cell textfield delegates all back to their actual cell object
    for(int i = 0; i < [self.tableView numberOfRowsInSection:0]; ++i) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        ListEventCell *cell = (ListEventCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if(cell.textField.delegate == self) [cell.textField setDelegate:cell];
    }
    
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    //if(textField.tag == TEXTFIELD_NAVIGATION_TITLE_TAG) return YES;
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

- (void)textFieldDidBeginEditing:(UITextField *)textField {

}

#pragma mark WYPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)popoverController {
    popover.delegate = nil;
    popover = nil;
}

#pragma mark UIViewController

- (void)viewDidLoad {

    [CustomCellColor initializeColors];
    [MemoryDataSource _load];
	

	
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController setNavigationBarHidden:YES];
//    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
//    [self.navigationController.navigationBar setBarTintColor:[UIColor w]];
    [super viewDidLoad];
    NSLog(@"last %f",_lastScale);
    _lastScale = 1.0;
	//CGRect oldFrame = self.tableView.frame;
	//CGRect newFrame = CGRectOffset(oldFrame, 0, -20);
	//[self.tableView setFrame:newFrame];
    
    // set up list set data source
    listSetDataSource = [ListSetDataSource sharedDataSource];
    
    ListSet *currentSet = [[ListSetDataSource sharedDataSource] listSetForCurrentKey];
    [[currentSet currentList] organizeEvents];
    
    // TODO :: not sure if i need this anymore
    if(!currentSet.currentList.currentCategory) {
        currentSet.currentList.currentCategory = @0;
        if(![currentSet.currentList eventsForCurrentCategory]) {
            //[currentSet.currentList incrementCategory];
        }
    }
    
    // display all events for all sets
    // TODO :: idk if this is the functionality i want
    // i think i need to figure out a way to show how many events there are / where events are
    // and then i won't need to do this
    // TODO :: will delete later once this ^ is implemented
    for(id key in [listSetDataSource sets]) {
        ListSet *listSet = [[listSetDataSource sets] objectForKey:key];
        [[listSet due] displayAllEvents];
        [[listSet completed] displayAllEvents];
        [[listSet deleted] displayAllEvents];
//        [[listSet currentList] displayAllEvents];
    }
    
    [self.tableView reloadData];
    
    // Do any additional setup after loading the view, typically from a nib.
    [self UIGestureRecognizersAreFun];
	
    // dont need this for now
//    [self setUpHeaderView];
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

// TODO :: integrate pop
// instead of deleting and inserting rows using uitableview methods,
// use pop to animate the tableview out, and animate the new tableview back in
// hmmm... idk if that will look good though, we'll see
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
    
    // TODO :: should i save here ?
    [MemoryDataSource save];
    list.recentlyAddedEvent = nil;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    // TODO :: something is going on with the table view tap / cell tap

    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        CGPoint location = [gestureRecognizer locationInView:self.view];
        if(location.x > 50 && location.x < self.view.frame.size.width - 50) {
            return NO;
        }
        
        CGPoint translation = [gestureRecognizer translationInView:self.view];
        return fabsf(translation.x) > fabsf(translation.y);
        
    }
    return YES;
}

// TODO :: this whole thing needs to be checked out
// the animation from deletion to insertion is awkward

// UPDATE :: fixed and i think it should be good now
// keep comments here so i can decide if i want to change anything later
- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer {

    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            POPSpringAnimation *tableViewSpring = [self.tableView pop_animationForKey:@"tableViewSpring"];
            if(tableViewSpring) {
                [self.tableView pop_removeAnimationForKey:@"tableViewSpring"];
            } else {
                
            }
            
            
            // get initial center and point of drag
            _originalCenter = self.tableView.center;
            _originalPoint = [gestureRecognizer locationInView:self.view];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            // get changing point and determine if we should change sets
            CGPoint translation = [gestureRecognizer translationInView:self.tableView];
            self.tableView.center = CGPointMake(_originalCenter.x + translation.x, _originalCenter.y);
            
            CGPoint endLocation = [gestureRecognizer locationInView:self.view];
            
            const int edge = 65;
            
            // TODO :: check this out
            _goToNextSetOnRelease = _originalPoint.x > self.view.frame.size.width-edge && endLocation.x < self.view.frame.size.width-edge;
            
            // TODO :: check this out
            _goToPreviousSetOnRelease = _originalPoint.x < edge && endLocation.x > edge;
            
            if(_goToNextSetOnRelease || _goToPreviousSetOnRelease) {
//                [self transitionNavCenters];
                // perform animation to
                // TODO :: check this out
                
                // if there is no list set to switch to,
                // then stay on current one
                if([listSetDataSource numberOfSets] <= 1) {
                    [gestureRecognizer setEnabled:NO];
                    [self animateResetTableView];
                    [gestureRecognizer setEnabled:YES];
                    return;
                }
                
                CGRect originalFrame = CGRectMake(0, self.tableView.frame.origin.y, self.tableView.bounds.size.width, self.tableView.bounds.size.height);
                
                
                /*
                POPSpringAnimation *tableViewSpring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
                
                tableViewSpring.toValue = [NSValue valueWithCGRect:originalFrame];
                tableViewSpring.springBounciness = 15;
                tableViewSpring.springSpeed = 6;
                [self.tableView pop_addAnimation:tableViewSpring forKey:@"tableViewSpring"];
                 */
                [self nextListSet:_goToNextSetOnRelease];
	[self updateListSetHeader];
                [self transitionNavCenters];
                
                
                // awesome hack to cancel the gesture
                
                [gestureRecognizer setEnabled:NO];
                [gestureRecognizer setEnabled:YES];
            
                // reset table view frame
                [UIView animateWithDuration:0.3 animations:^{
                  self.tableView.frame = originalFrame;
                }];
                // go to next/previous list set
                
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {/*
            if(_goToNextSetOnRelease || _goToPreviousSetOnRelease) {
                // perform animation to
                // TODO :: check this out
                CGRect originalFrame = CGRectMake(0, self.tableView.frame.origin.y, self.tableView.bounds.size.width, self.tableView.bounds.size.height);

                POPSpringAnimation *tableViewSpring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
                
                tableViewSpring.toValue = [NSValue valueWithCGRect:originalFrame];
                tableViewSpring.springBounciness = 15;
                tableViewSpring.springSpeed = 10;
                [self.tableView pop_addAnimation:tableViewSpring forKey:@"tableViewSpring"];
                [self nextListSet:_goToNextSetOnRelease];
                // reset table view frame
                //[UIView animateWithDuration:0.3 animations:^{
                  //  self.tableView.frame = originalFrame;
                //}];
                // go to next/previous list set

            } else {*/
                // reset table view position
            [self animateResetTableView];
            [self transitionNavCenters];
                
                //[UIView animateWithDuration:0.2 animations:^{
                //    self.tableView.frame = originalFrame;
                //}];
            //}
            //[self transitionNavCenters];
            //[self hideNavCenters];
            break;
        }
        default:
            break;
    }
}

- (void)animateResetTableView {
    
    CGRect originalFrame = CGRectMake(0, self.tableView.frame.origin.y, self.tableView.bounds.size.width, self.tableView.bounds.size.height);
    
    POPSpringAnimation *tableViewSpring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    
    tableViewSpring.toValue = [NSValue valueWithCGRect:originalFrame];
    tableViewSpring.springBounciness = 15;
    tableViewSpring.springSpeed = 10;
    [self.tableView pop_addAnimation:tableViewSpring forKey:@"tableViewSpring"];
}

- (void)transitionNavCenters {
    // TODO :: current big nav center
    // implement a method to get the current big nav center
    // rather than animating it every time even if it is already big
    int currentList = [[[listSetDataSource listSetForCurrentKey] _currentList] intValue];
    if(currentList == 0) {
        [self animateDeletedBig];
    } else if(currentList == 1) {
        [self animateDueBig];
    } else if(currentList == 2) {
        [self animateCompletedBig];
    }
}

- (void)enableTableViewTap {
    [_tableViewTapRecognizer setEnabled:YES];
}

- (void)disableTableViewTap {
    [_tableViewTapRecognizer setEnabled:NO];
}

- (void)UIGestureRecognizersAreFun {
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] init];
    [pinchRecognizer addTarget:self action:@selector(pinchedCells:)];
    [self.tableView addGestureRecognizer:pinchRecognizer];
    
    _tableViewTapRecognizer = [[UITapGestureRecognizer alloc] init];
    [_tableViewTapRecognizer addTarget:self action:@selector(didTapTableView:)];
    [self.tableView addGestureRecognizer:_tableViewTapRecognizer];
    [self disableTableViewTap];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] init];
    [panRecognizer addTarget:self action:@selector(handlePanGesture:)];
    [panRecognizer setDelegate:self];
    [self.tableView addGestureRecognizer:panRecognizer];
    
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
    
    
    [self setUpNavCenters];
    
}

- (void)setUpNavCenters {
    [[self.deletedImageView layer] setCornerRadius:_deletedImageView.frame.size.height/2];
    [[self.eventsImageView layer] setCornerRadius:_eventsImageView.frame.size.height/2];
    [[self.completedImageView layer] setCornerRadius:_completedImageView.frame.size.height/2];
    
//    UIImageView *trashImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"to-do-icon-rough2.png"]];
//    [trashImageView setFrame:_eventsImageView.frame];
//    [self.eventsImageView addSubview:trashImageView];
}

#pragma mark List Set Stuff

- (void)addListSet {
    ListSet *newListSet = [[ListSet alloc] init];
    [listSetDataSource addSet:newListSet];
}

- (void)nextListSet:(BOOL)next {
    List *currentList = [[listSetDataSource listSetForCurrentKey] currentList];
    [currentList organizeEvents];
//    [[[listSetDataSource listSetForCurrentKey] currentList] organizeEvents];
    
    if(shouldUpdateSortIds) [currentList updateSortIds];
    shouldUpdateSortIds = NO;
    
    if([ListEventCell selectedIndex]) {
        int numberOfEvents = [[[listSetDataSource listSetForCurrentKey] currentList] numberOfEventsForCurrentCategory];
        for(int i = 0; i < numberOfEvents; ++i) {
            ListEventCell *cell = (ListEventCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell setExpanded:NO];
        }
        [ListEventCell setSelectedIndex:-1];
    }
    
    [self.tableView beginUpdates];
    //[self deleteAllEventsFromTableViewInDirection:UITableViewRowAnimationFade];
    [self deleteAllEventsFromTableViewInDirection:(next ? UITableViewRowAnimationLeft : UITableViewRowAnimationRight)];
    next ? [listSetDataSource incrementKey] : [listSetDataSource decrementKey];
    //[self insertEvents:[[listSetDataSource listSetForCurrentKey] currentList] inDirection:UITableViewRowAnimationFade];
    [self insertEvents:[[listSetDataSource listSetForCurrentKey] currentList] inDirection:(next ? UITableViewRowAnimationRight : UITableViewRowAnimationLeft)];
    [self.tableView endUpdates];
    
    // TODO :: take this out
    // TODO :: change this to MemoryCard
    [MemoryDataSource save];
}

@end
