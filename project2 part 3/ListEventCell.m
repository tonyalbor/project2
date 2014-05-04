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
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
    [longPress addTarget:self action:@selector(longPressedCell:)];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] init];
    [pan addTarget:self action:@selector(pannedCell:)];
    
    [self addGestureRecognizer:pan];
    [self addGestureRecognizer:tap];
    [self addGestureRecognizer:longPress];
}

-(BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:[self superview]];
    // Check for horizontal gesture
    if (fabsf(translation.x) > fabsf(translation.y)) {
        return YES;
    }
    return NO;
}

- (void)pannedCell:(UIPanGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            _originalCenter = self.center;
            _originalPoint = [gestureRecognizer translationInView:self];
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [gestureRecognizer translationInView:self];
            self.center = CGPointMake(_originalCenter.x + translation.x, _originalCenter.y);
            _completeOnDragRelease = translation.x - _originalPoint.x > self.frame.size.width / 3;
            _deleteOnDragRelease = _originalPoint.x - translation.x > self.frame.size.width / 3;
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if(_completeOnDragRelease) {
                [_delegate cellPanned:gestureRecognizer shouldComplete:YES shouldDelete:NO];
            } else if(_deleteOnDragRelease) {
                [_delegate cellPanned:gestureRecognizer shouldComplete:NO shouldDelete:YES];
            } else {
                // reset cell position
                CGRect originalFrame = CGRectMake(0, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height);
                [UIView animateWithDuration:0.2 animations:^ {
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
