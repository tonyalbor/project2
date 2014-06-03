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
        [self removeSubviews];
        
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
    
    self.textField.keyboardAppearance = UIKeyboardAppearanceDark;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.clipsToBounds = YES;
    
    [_textField setUserInteractionEnabled:NO];
    [_textField setDelegate:self];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(didTapCell:)];
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
                cellSpring.springBounciness = 15;
                cellSpring.springSpeed = 10;

                [self pop_addAnimation:cellSpring forKey:@"cellSpring"];
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
        [self didTapCell:nil];
        return NO;
    }
    
}

- (void)didTapCell:(UITapGestureRecognizer *)gestureRecognizer {
    UIImageView *pencilImageView = (UIImageView *)[self.contentView viewWithTag:111];
    if(pencilImageView) {
        CGPoint touchLocation = [gestureRecognizer locationInView:self.contentView];
        
        if(CGRectContainsPoint(pencilImageView.frame, touchLocation)) {
            NSLog(@"touched image view");
            [self didTapPencil:gestureRecognizer];
            return;
        } else {
            NSLog(@"didnt touch image view");
        }
    }
    
    if(selectedIndex == -1) {
        // nothing is expanded; color
        [_delegate changeCellColor:self];
        //[_delegate cellTapped:self];
    } else if(_isExpanded) {
        // self is expanded; collapse
       // [self removeSubviews];
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

- (void)didTapPencil:(UITapGestureRecognizer *)gestureRecognizer {
    [self animatePencil:gestureRecognizer];
    
}

- (void)animatePencil:(UITapGestureRecognizer *)gestureRecognizer {
    id pencilImageView = [self.contentView viewWithTag:111];
    CGRect originalFrame = ((UIImageView *)pencilImageView).frame;
    
    [UIView animateWithDuration:.2 animations:^{
        CGRect newFrame = CGRectInset(originalFrame, -originalFrame.size.width/4, -originalFrame.size.height/4);
        [pencilImageView setFrame:newFrame];
    } completion:^(BOOL finsished) {
        if(finsished) {
            POPSpringAnimation *spring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
            spring.toValue = [NSValue valueWithCGRect:originalFrame];
            spring.springBounciness = 15;
            spring.springSpeed = 10;
            [pencilImageView pop_addAnimation:spring forKey:@"pencil-image-view-pop-spring"];
        }
    }];
    
}

- (void)addSubviews {
    UIImageView *pencilImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pencil.png"]];
    [pencilImageView setFrame:CGRectMake(self.eventLabel.frame.origin.x / 4, self.eventLabel.frame.origin.y + 150, 25, 25)];
    [pencilImageView setTag:111];
    [pencilImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapPencil = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPencil:)];
    [pencilImageView addGestureRecognizer:tapPencil];
    [self.contentView addSubview:pencilImageView];
    
    UIImageView *otherImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pencil.png"]];
    [otherImageView setFrame:CGRectOffset(pencilImageView.frame, 0, -75)];
    [otherImageView setTag:112];
    [self.contentView addSubview:otherImageView];
}

- (void)removeSubviews {
    id view = [self.contentView viewWithTag:111];
    if(view) [view removeFromSuperview];
    
    id other = [self.contentView viewWithTag:112];
    if(other) [other removeFromSuperview];
}

@end
