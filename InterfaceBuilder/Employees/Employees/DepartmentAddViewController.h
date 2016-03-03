//
//  DepartmentAddViewController.h
//  Employees
//
//  Created by DongMeiliang on 3/2/16.
//  Copyright © 2016 Meiliang Dong. All rights reserved.
//

@import CoreData;

#import <XLForm/XLForm.h>

@protocol DepartmentAddDelegate;

@interface DepartmentAddViewController : XLFormViewController

@property (nonatomic, weak) id<DepartmentAddDelegate> delegate;

@end

@protocol DepartmentAddDelegate <NSObject>

// department == nil on cancel
- (void)departmentAddViewController:(DepartmentAddViewController *)departmentAddViewController didAddDepartment:(NSDictionary *)department;

@end