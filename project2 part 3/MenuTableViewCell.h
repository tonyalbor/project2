//
//  MenuTableViewCell.h
//  project2 part 3
//
//  Created by Tony Albor on 5/8/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GBFlatButton.h>

@interface MenuTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *listSetTitleLabel;

@property (strong, nonatomic) IBOutlet GBFlatButton *deletedCountView;

@property (strong, nonatomic) IBOutlet GBFlatButton *dueCountView;

@property (strong, nonatomic) IBOutlet GBFlatButton *completedCountView;

@end
