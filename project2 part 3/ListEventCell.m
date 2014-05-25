//
//  ListEventCell.m
//  project2 part 3
//
//  Created by Tony Albor on 9/8/13.
//  Copyright (c) 2013 tonyalbor. All rights reserved.
//

#import "ListEventCell.h"
#import <POP/POP.h>

@implementation ListEventCell {
    CGPoint _originalCenter;
    CGPoint _originalPoint;
	BOOL _deleteOnDragRelease;
    BOOL _completeOnDragRelease;
    
    CGFloat _cellHeight;
    BOOL _isExpanded;
}

static int selectedIndex = -1;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _isExpanded = NO;
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initWithGestureRecognizers {
    if(self.gestureRecognizers.count == 3) return;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.clipsToBounds = YES;
    
    [_textField setUserInteractionEnabled:YES];
    [_textField setDelegate:self];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(didTapCell)];
    [tap setDelegate:self];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
    [longPress addTarget:self action:@selector(didLongPressCell:)];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] init];
    [pan addTarget:self action:@selector(pannedCell:)];
    [pan setDelegate:self];
    
    [self addGestureRecognizer:pan];
    [self addGestureRecognizer:tap];
    [self addGestureRecognizer:longPress];
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return YES;
    }
    CGPoint location = [gestureRecognizer locationInView:[self superview]];
    if(location.x < 50 || location.x > self.superview.frame.size.width - 50) {
        return NO;
    }
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint translation = [gestureRecognizer translationInView:[self superview]];
        // Check for horizontal gesture
        if (fabsf(translation.x) > fabsf(translation.y)) {
            return YES;
        }
        return NO;
    }
    return YES;
    
}
/*
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}
*/
- (void)pannedCell:(UIPanGestureRecognizer *)gestureRecognizer {
    //if(_originalPoint.x < 50 || _originalPoint.x > self.frame.size.width - 50) return;
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            _originalCenter = self.center;
            _originalPoint = [gestureRecognizer locationInView:self];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [gestureRecognizer translationInView:self];
            
            self.center = CGPointMake(_originalCenter.x + translation.x, _originalCenter.y);
            
            // end location for cell superview, cell location moves along with pan
            //cell superview is uitableviewwrapperview
            CGPoint endLocation = [gestureRecognizer locationInView:self.superview];
            
            _completeOnDragRelease = endLocation.x - _originalPoint.x > self.contentView.frame.size.width / 3;
            _deleteOnDragRelease = _originalPoint.x - endLocation.x > self.contentView.frame.size.width / 3;
            break;
        }
        case UIGestureRecognizerStateEnded: {
            
            if(_completeOnDragRelease || _deleteOnDragRelease) {
                [_delegate cellPanned:gestureRecognizer complete:_completeOnDragRelease delete:_deleteOnDragRelease];
            } else {
                // reset cell position
                
                
                POPSpringAnimation *cellSpring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];

                
                
                CGRect originalFrame = CGRectMake(0, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height);
                
                cellSpring.toValue = [NSValue valueWithCGRect:originalFrame];
                cellSpring.springBounciness = 14;
                cellSpring.springSpeed = 7;

                [self pop_addAnimation:cellSpring forKey:@"cellSpring"];
//                [UIView animateWithDuration:0.2 animations:^{
//                  self.frame = originalFrame;
//                }];
            }
            break;
        }
        default:
            break;
    }
}

- (BOOL)isExpanded {
    return _isExpanded;
}

- (void)setExpanded:(BOOL)expanded {
    _isExpanded = expanded;
}

+ (int)selectedIndex {
    return selectedIndex;
}

+ (void)setSelectedIndex:(int)index {
    selectedIndex = index;
}

- (CGFloat)cellHeight {
    return _cellHeight;
}

- (void)setCellHeight:(CGFloat)height {
    _cellHeight = height;
}

/**
 *  Two Cases
 *  1) creating new cell => change textfield delegate to view controller; return YES
 *  2) tap on existing textfield within existing cell => [self didTapCell]; return NO
 */
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    // cell textfield's delegate is originally the cell;
    // once the textfield shows up, i change the delegate to the view controller;
    // that way the view controller can handle the input of multiple cells
    // by tapping on screen while keyboard is up (one keyboard for tableview,
    // opposed to one keyboard per cell);
    
    if([_delegate isCreatingNewCell]) {
        id<UITextFieldDelegate>newDelegate = (id)_delegate;
        textField.delegate = newDelegate;
        return YES;
    } else {
        [self didTapCell];
        return NO;
    }
    
}

- (void)didTapCell {
    
    if(selectedIndex == -1) {
        // nothing is expanded; color
        [_delegate changeCellColor:self];
        //[_delegate cellTapped:self];
    } else if(_isExpanded) {
        // self is expanded; collapse
        NSLog(@"right about to crash");
        [_delegate collapseCell:self];
        _isExpanded = NO;
    } else if(selectedIndex >= 0) {
        // something else is expanded; collapse that something else
        [_delegate collapseCellAtIndex:selectedIndex];
    }
}

// TODO :: if _isExpanded crashes
- (void)didLongPressCell:(UILongPressGestureRecognizer *)gestureRecognizer {


    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {

        NSLog(@"selected index %d is expanded %d",selectedIndex,_isExpanded);
    if(selectedIndex == -1) {
        // nothing is expanded; expand
        [_delegate expandCell:self];
        _isExpanded = YES;
    } else if(_isExpanded) {
        // self is expanded; collapse
        NSLog(@"right about to crash");
        [_delegate collapseCell:self];
        _isExpanded = NO;
    } else if(selectedIndex >= 0) {
        // something else is expanded; collapse currently expanded; expand self
        // TODO :: animation
        [_delegate collapseCellAtIndex:selectedIndex];
        [_delegate expandCell:self];
        _isExpanded = YES;
    } else {
        NSLog(@"TROLOLOL");
    }
    } else {
        
    }
}

- (void)layoutSubviews {
    
}

- (void)addSubviews {

}

@end
