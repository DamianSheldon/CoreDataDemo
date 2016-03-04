//
//  EmployeeSelectViewController.h
//  Employees
//
//  Created by DongMeiliang on 3/3/16.
//  Copyright © 2016 Meiliang Dong. All rights reserved.
//

@import CoreData;

#import <UIKit/UIKit.h>

@interface EmployeeSelectViewController : UITableViewController

@property (nonatomic) NSManagedObject *targetDepartment;

@end
