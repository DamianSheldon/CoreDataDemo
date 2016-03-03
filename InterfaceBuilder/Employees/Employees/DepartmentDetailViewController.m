//
//  DepartmentDetailViewController.m
//  Employees
//
//  Created by DongMeiliang on 3/3/16.
//  Copyright © 2016 Meiliang Dong. All rights reserved.
//

#import "Employee.h"
#import "DataController.h"
#import "NotificationNames.h"

#import "DepartmentDetailViewController.h"
#import "EmployeeAddViewController.h"
#import "EmployeeSelectViewController.h"

@interface DepartmentDetailViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (nonatomic) UITableView *tableView;

@property (nonatomic) NSMutableArray *employees;
@property (nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation DepartmentDetailViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Department Employees";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(handleItemAddTapped)];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSSet *oldEmployees = [self.department valueForKey:@"employees"];
    if (oldEmployees.count > 0) {
        self.employees = [NSMutableArray arrayWithCapacity:oldEmployees.count];
        [oldEmployees enumerateObjectsUsingBlock:^(id obj, BOOL * _Nonnull stop) {
            [self.employees addObject:obj];
        }];
    }
    else {
        self.employees = [NSMutableArray arrayWithCapacity:64];
    }
    
    [self.view addSubview:self.tableView];
    [self configureConstraintsForTableView];
    
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
    return self.employees.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *sCellIdentifier = @"DepartmentCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:sCellIdentifier];
    }
    
    Employee *employee = self.employees[indexPath.row];
    
    cell.textLabel.text = [employee valueForKey:@"name"];
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:employee.startDate];
    
    return cell;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.firstOtherButtonIndex) {
        EmployeeAddViewController *employeeAddVC = [EmployeeAddViewController new];
        employeeAddVC.targetDepartment = self.department;
        
        [self.navigationController pushViewController:employeeAddVC animated:YES];
    }
    else if (buttonIndex == actionSheet.firstOtherButtonIndex + 2) {
        EmployeeSelectViewController *employeeSelectVC = [EmployeeSelectViewController new];
        employeeSelectVC.targetDepartment = self.department;
        
        [self.navigationController pushViewController:employeeSelectVC animated:YES];
    }
}

#pragma mark - Notification

- (void)handleAddEmployeeNotification
{
    NSSet *newEmployees = [self.department valueForKey:@"employees"];

    [self.employees removeAllObjects];
    [newEmployees enumerateObjectsUsingBlock:^(id obj, BOOL * _Nonnull stop) {
        [self.employees addObject:obj];
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Event Handler

- (void)handleItemAddTapped
{
    // Is there any employee who isn't in this department?
    NSError *error;
    NSArray *employeesOfOtherDepartment = [[DataController sharedDataController] employeesNotInDepartment:self.department error:&error];
    if (error) {
        NSLog(@"Fetch other department's employee error:%@", error.localizedDescription);
    }
    
    BOOL isShowAddEmployeeEntry;
    
    if (employeesOfOtherDepartment.count > 0) {
        isShowAddEmployeeEntry = YES;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"New a employee", nil];
    if (isShowAddEmployeeEntry) {
        [actionSheet addButtonWithTitle:@"Add a employee"];
    }
    
    [actionSheet showInView:self.view];
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

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    return _dateFormatter;
}

@end
