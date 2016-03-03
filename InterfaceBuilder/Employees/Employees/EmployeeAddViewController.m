//
//  EmployeeAddViewController.m
//  Employees
//
//  Created by DongMeiliang on 3/3/16.
//  Copyright © 2016 Meiliang Dong. All rights reserved.
//

#import "Employee.h"
#import "DataController.h"
#import "NotificationNames.h"

#import "EmployeeAddViewController.h"

static NSString *const sBirthOfDate = @"dateOfBirth";
static NSString *const sName = @"name";
static NSString *const sStartDate = @"startDate";

@interface EmployeeAddViewController ()

@end

@implementation EmployeeAddViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Add Employee";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    
    [self initializeForm];
}

#pragma mark - Event Handler

- (void)cancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)done
{
    NSArray *validationErrors = [self formValidationErrors];
    if (validationErrors.count > 0){
        [self showFormValidationError:[validationErrors firstObject]];
        return;
    }
    
    NSMutableDictionary *formValues = [[self formValues] mutableCopy];
    [formValues setObject:self.targetDepartment forKey:@"department"];
    
    NSError *error;
    [[DataController sharedDataController] insertEmployee:formValues error:&error];
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add Employee" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:DepartmentDidAddEmployeeNotification object:self];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Private Method

- (void)initializeForm
{
    XLFormDescriptor *formDescriptor = [XLFormDescriptor formDescriptor];
    
    XLFormSectionDescriptor *sectionDescriptor = [XLFormSectionDescriptor formSection];
    [formDescriptor addFormSection:sectionDescriptor];
    
    XLFormRowDescriptor *rowDescriptor = [XLFormRowDescriptor formRowDescriptorWithTag:sName rowType:XLFormRowDescriptorTypeText title:@"Name"];
    rowDescriptor.required = YES;
    
    [sectionDescriptor addFormRow:rowDescriptor];
    
    rowDescriptor = [XLFormRowDescriptor formRowDescriptorWithTag:sStartDate rowType:XLFormRowDescriptorTypeDateInline title:@"Start Date"];
    rowDescriptor.required = YES;
    rowDescriptor.value = [NSDate date];
    [sectionDescriptor addFormRow:rowDescriptor];
    
    rowDescriptor = [XLFormRowDescriptor formRowDescriptorWithTag:sBirthOfDate rowType:XLFormRowDescriptorTypeDateInline title:@"Birth Of Date"];
    [sectionDescriptor addFormRow:rowDescriptor];
    
    self.form = formDescriptor;
}


@end
