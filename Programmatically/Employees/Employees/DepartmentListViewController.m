//
//  ViewController.m
//  Employees
//
//  Created by DongMeiliang on 3/2/16.
//  Copyright © 2016 Meiliang Dong. All rights reserved.
//

#import "DataController.h"
#import "NotificationNames.h"

#import "DepartmentListViewController.h"
#import "DepartmentAddViewController.h"
#import "DepartmentDetailViewController.h"

@interface DepartmentListViewController ()<UITableViewDataSource, UITableViewDelegate, DepartmentAddDelegate>

@property (nonatomic) UITableView *tableView;

@property (nonatomic, copy) NSArray *departments;

@end

@implementation DepartmentListViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Departments";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(handleItemAddTapped)];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.tableView];
    [self configureConstraintsForTableView];
    
    self.departments = [[DataController sharedDataController] departmentsMayResultWithError:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAddEmployeeNotification) name:DepartmentDidAddEmployeeNotification object:nil];
}

#pragma mark - Layout

- (void)configureConstraintsForTableView
{
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.departments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *sCellIdentifier = @"DepartmentCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sCellIdentifier];
    }
    
    NSManagedObject *department = self.departments[indexPath.row];
    
    cell.textLabel.text = [department valueForKey:@"name"];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSManagedObject *department = self.departments[indexPath.row];
    
    DepartmentDetailViewController *departmentDetailVC = [DepartmentDetailViewController new];
    departmentDetailVC.department = department;
    
    [self.navigationController pushViewController:departmentDetailVC animated:YES];
}

#pragma mark - DepartmentAddDelegate

- (void)departmentAddViewController:(DepartmentAddViewController *)departmentAddViewController didAddDepartment:(NSDictionary *)department
{
    if (department) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.departments = [[DataController sharedDataController] departmentsMayResultWithError:nil];
            [self.tableView reloadData];
        });
    }
}

#pragma mark - Notification

- (void)handleAddEmployeeNotification
{
    self.departments = [[DataController sharedDataController] departmentsMayResultWithError:nil];
}

#pragma mark - Event Handler

- (void)handleItemAddTapped
{
    DepartmentAddViewController *departmentAddVC = [DepartmentAddViewController new];
    departmentAddVC.delegate = self;
    
    [self.navigationController pushViewController:departmentAddVC animated:YES];
}

#pragma mark - Getter

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

@end
