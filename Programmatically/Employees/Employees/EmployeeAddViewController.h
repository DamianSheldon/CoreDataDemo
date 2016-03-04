//
//  EmployeeAddViewController.h
//  Employees
//
//  Created by DongMeiliang on 3/3/16.
//  Copyright © 2016 Meiliang Dong. All rights reserved.
//

@import CoreData;

#import <XLForm/XLForm.h>

@interface EmployeeAddViewController : XLFormViewController

@property (nonatomic) NSManagedObject *targetDepartment;

@end
