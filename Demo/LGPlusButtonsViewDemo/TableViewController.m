//
//  TableViewController.m
//  LGPlusButtonsViewDemo
//
//  Created by Grigory Lutkov on 26.02.15.
//  Copyright (c) 2015 Grigory Lutkov. All rights reserved.
//

#import "TableViewController.h"
#import "PlusViewController.h"
#import "PlusScrollViewController.h"

@interface TableViewController ()

@property (strong, nonatomic) NSArray *titlesArray;

@end

@implementation TableViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        self.title = @"LGPlusButtonsView";

        _titlesArray = @[@"UIView",
                         @"UIScrollView"];

        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];

        self.clearsSelectionOnViewWillAppear = YES;
    }
    return self;
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titlesArray.count;
}

#pragma mark - UITableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    cell.textLabel.font = [UIFont systemFontOfSize:16.f];
    cell.textLabel.text = _titlesArray[indexPath.row];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        PlusViewController *viewController = [[PlusViewController alloc] initWithTitle:_titlesArray[indexPath.row]];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if (indexPath.row == 1)
    {
        PlusScrollViewController *viewController = [[PlusScrollViewController alloc] initWithTitle:_titlesArray[indexPath.row]];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

@end
