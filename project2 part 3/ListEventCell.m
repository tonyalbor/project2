//
//  ListEventCell.m
//  project2 part 3
//
//  Created by Tony Albor on 9/8/13.
//  Copyright (c) 2013 tonyalbor. All rights reserved.
//

#import "ListEventCell.h"

@implementation ListEventCell {
    CGPoint _originalCenter;
    CGPoint _originalPoint;
	BOOL _deleteOnDragRelease;
    BOOL _completeOnDragRelease;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(tappedCell:)];
    [tap setDelegate:self];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
    [longPress addTarget:self action:@selector(longPressedCell:)];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] init];
    [pan addTarget:self action:@selector(pannedCell:)];
    [pan setDelegate:self];
    
    [self addGestureRecognizer:pan];
    [self addGestureRecognizer:tap];
    [self addGestureRecognizer:longPress];
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {

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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

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
                CGRect originalFrame = CGRectMake(0, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height);
                [UIView animateWithDuration:0.2 animations:^{
                    self.frame = originalFrame;
                }];
            }
            break;
        }
        default:
            break;
    }
}

- (void)tappedCell:(UITapGestureRecognizer *)gestureRecognizer {
    [_delegate cellTapped:gestureRecognizer];
}

- (void)longPressedCell:(UILongPressGestureRecognizer *)gestureRecognizer {
    [_delegate cellLongPressed:gestureRecognizer];
}

@end
