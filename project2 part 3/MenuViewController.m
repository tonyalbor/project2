//
//  MenuViewController.m
//  project2 part 3
//
//  Created by Tony Albor on 5/7/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import "MenuViewController.h"
#import "ListSetDataSource.h"
#import "ListSet.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

#define ADD_SET_ROW 1

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[[ListSetDataSource sharedDataSource] sets] allKeys] count] + ADD_SET_ROW;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"menuCell"];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == [self.tableView numberOfRowsInSection:0]-1) {
        [cell.textLabel setText:@"Add Set"];
        return;
    }
    
    ListSet *currentSet = [[[ListSetDataSource sharedDataSource] sets] objectForKey:@(indexPath.row)];
    [cell.textLabel setText:currentSet.title];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    indexPath.row == [tableView numberOfRowsInSection:0]-1 ? [_delegate didSelectAddSet] : [_delegate didSelectListSetAtIndexPath:indexPath];
}

- (void)setDelegate:(id<MenuViewControllerDelegate>)delegate {
    _delegate = delegate;
}

- (void)viewDidLoad
{
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
