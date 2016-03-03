//
//  DataController.m
//  Employees
//
//  Created by DongMeiliang on 3/2/16.
//  Copyright © 2016 Meiliang Dong. All rights reserved.
//

@import CoreData;

#import "DataController.h"

@interface DataController ()

@property (nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation DataController

+ (instancetype)sharedDataController
{
    static DataController *sSharedDataController;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sSharedDataController) {
            sSharedDataController = [[self alloc] initWithSingleton];
        }
    });
    return sSharedDataController;
}

#pragma mark - Private Methods

- (instancetype)initWithSingleton
{
    self = [super init];
    if (self) {
        [self initializeCoreData];
    }
    return self;
}

- (void)initializeCoreData
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Workspace" withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSAssert(mom != nil, @"Error initializing Managed Object Model");
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:psc];
    [self setManagedObjectContext:moc];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentsURL URLByAppendingPathComponent:@"Workspace.sqlite"];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSError *error = nil;
        NSPersistentStoreCoordinator *psc = [[self managedObjectContext] persistentStoreCoordinator];
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
        NSAssert(store != nil, @"Error initializing PSC: %@\n%@", [error localizedDescription], [error userInfo]);
    });
}

#pragma mark - Public Methods

- (BOOL)insertDepartment:(NSDictionary *)department error:(NSError **)error
{
    NSManagedObject *departmentMO = [NSEntityDescription insertNewObjectForEntityForName:@"Department" inManagedObjectContext:self.managedObjectContext];
    [departmentMO setValue:department[@"name"] forKey:@"name"];
    NSArray *employees = department[@"employees"];
    if (employees) {
        [departmentMO setValue:employees forKey:@"employees"];
    }
    
    return [self.managedObjectContext save:error];
}

- (BOOL)insertEmployee:(NSDictionary *)employee error:(NSError **)error
{
    Employee *employeeMO = [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:self.managedObjectContext];
    
    NSDate *dateOfBirth = employee[@"dateOfBirth"];
    if ([dateOfBirth isKindOfClass:[NSDate class]]) {
        [employeeMO setValue:dateOfBirth forKey:@"dateOfBirth"];
    }
    
    [employeeMO setValue:employee[@"name"] forKey:@"name"];
    [employeeMO setValue:employee[@"startDate"] forKey:@"startDate"];
    employeeMO.department = employee[@"department"];
    
    return [self.managedObjectContext save:error];
}

- (NSArray *)departmentsMayResultWithError:(NSError **)error
{
    /*
     Fetch existing departments.
     Create a fetch request for the Event entity; add a sort descriptor; then execute the fetch.
     */
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Department"];
    
    // Order the department by alpha.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    // Execute the fetch.
    NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:request error:error];
    
    return fetchResults;
}

- (NSArray *)employeesMayResultWithError:(NSError **)error
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Employee"];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:request error:error];
    
    return fetchResults;
}

- (BOOL)updateDepartment:(NSManagedObject *)department error:(NSError **)error
{
    return [self.managedObjectContext save:error];
}

- (BOOL)updateEmployee:(Employee *)employee error:(NSError **)error
{
    return [self.managedObjectContext save:error];
}

- (BOOL)updateEmployees:(NSArray *)employees error:(NSError **)error
{
    return [self.managedObjectContext save:error];
}

- (BOOL)deleteDepartment:(NSManagedObject *)department error:(NSError **)error
{
    [self.managedObjectContext deleteObject:department];
    
    return [self.managedObjectContext save:error];
}

- (BOOL)deleteEmployee:(Employee *)employee error:(NSError **)error
{
    [self.managedObjectContext deleteObject:employee];
    
    return [self.managedObjectContext save:error];
}

- (NSArray *)employeesNotInDepartment:(NSManagedObject *)department error:(NSError **)error
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Employee"
                                              inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"department.name != %@", [department valueForKey:@"name"]];
    [request setPredicate:predicate];
    
    return [self.managedObjectContext executeFetchRequest:request error:error];
}

@end
