//
//  DataController.h
//  Employees
//
//  Created by DongMeiliang on 3/2/16.
//  Copyright © 2016 Meiliang Dong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Employee.h"

@interface DataController : NSObject

+ (instancetype)sharedDataController;

- (BOOL)insertDepartment:(NSDictionary *)department error:(NSError **)error;

- (BOOL)insertEmployee:(NSDictionary *)employee error:(NSError **)error;

- (NSArray *)departmentsMayResultWithError:(NSError **)error;

- (NSArray *)employeesMayResultWithError:(NSError **)error;

- (BOOL)updateDepartment:(NSManagedObject *)department error:(NSError **)error;

- (BOOL)updateEmployee:(Employee *)employee error:(NSError **)error;

- (BOOL)updateEmployees:(NSArray *)employees error:(NSError **)error;

- (BOOL)deleteDepartment:(NSManagedObject *)department error:(NSError **)error;

- (BOOL)deleteEmployee:(Employee *)employee error:(NSError **)error;

- (NSArray *)employeesNotInDepartment:(NSManagedObject *)department error:(NSError **)error;

@end
