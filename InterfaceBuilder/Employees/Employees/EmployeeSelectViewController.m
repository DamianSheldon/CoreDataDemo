//
//  EmployeeSelectViewController.m
//  Employees
//
//  Created by DongMeiliang on 3/3/16.
//  Copyright © 2016 Meiliang Dong. All rights reserved.
//

#import "DataController.h"
#import "NotificationNames.h"
#import "Employee.h"

#import "EmployeeSelectViewController.h"

@interface EmployeeSelectViewController ()

@property (nonatomic) NSArray *employees;

@end

@implementation EmployeeSelectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    NSError *error;
    self.employees = [[DataController sharedDataController] employeesNotInDepartment:self.targetDepartment error:&error];
    if (error) {
        NSLog(@"Fetch employee of other department error:%@", error.localizedDescription);
    }
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.tableView setEditing:YES animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.employees.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *sCellIdentifier = @"EmployeeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sCellIdentifier];
    }
    // Configure the cell...
    Employee *employee = self.employees[indexPath.row];
    cell.textLabel.text = [employee valueForKey:@"name"];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Update the delete button's title based on how many items are selected.
    [self updateButtonsToMatchTableState];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Update the delete button's title based on how many items are selected.
    [self updateButtonsToMatchTableState];
}

#pragma mark - Event Handler

- (void)cancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)done
{
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    
    NSMutableArray *selectedEmployees = [NSMutableArray arrayWithCapacity:selectedRows.count];
    
    [selectedRows enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        Employee *employee = self.employees[indexPath.row];
        employee.department = self.targetDepartment;
        
        [selectedEmployees addObject:employee];
    }];
    
    NSError *error;
    BOOL success = [[DataController sharedDataController] updateEmployees:selectedEmployees.copy error:&error];
    if (success) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DepartmentDidAddEmployeeNotification object:self];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Select Employee" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }
}

#pragma mark - Private Method

- (void)updateButtonsToMatchTableState
{
    // Update the delete button's title, based on how many items are selected
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    
    BOOL noItemsAreSelected = selectedRows.count == 0;
    self.navigationItem.rightBarButtonItem.enabled = !noItemsAreSelected;
}

@end
