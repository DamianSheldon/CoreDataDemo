//
//  DepartmentAddViewController.m
//  Employees
//
//  Created by DongMeiliang on 3/2/16.
//  Copyright © 2016 Meiliang Dong. All rights reserved.
//

@import CoreData;

#import "DataController.h"

#import "DepartmentAddViewController.h"

static NSString *sName = @"name";

@interface DepartmentAddViewController ()

@end

@implementation DepartmentAddViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Add Department";
    
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
    
    NSDictionary *formValues = [self formValues];
    
    NSError *error;
    [[DataController sharedDataController] insertDepartment:formValues error:&error];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add Department" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else {
        if ([self.delegate respondsToSelector:@selector(departmentAddViewController:didAddDepartment:)]) {
            [self.delegate departmentAddViewController:self didAddDepartment:formValues];
        }
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
    
    self.form = formDescriptor;
}

@end
