//
//  DBManager.m
//  Kir_Ter_SimplePin
//
//  Created by Admin on 7/14/16.
//  Copyright © 2016 KirillTer. All rights reserved.
//

#import "DBManager.h"

@implementation DBManager

+ (DBManager*) sharedManager{
    static DBManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[DBManager alloc] init];
    });
    return sharedManager;
}

- (Pins*) savePin:(CLLocationCoordinate2D) coordinates withUserID:(NSString*) userID{
    Pins* pin = [NSEntityDescription insertNewObjectForEntityForName:@"Pins" inManagedObjectContext:self.managedObjectContext];
    pin.latitude = [NSNumber numberWithDouble:(double)coordinates.latitude];
    pin.longitude = [NSNumber numberWithDouble:(double)coordinates.longitude];
    pin.userID = userID;
    [self saveContext];
    return pin;
}

- (Pins*) getCurrentPin:(CLLocationCoordinate2D) coordinates{
    double latitude = coordinates.latitude;
    double longitude = coordinates.longitude;
    NSPredicate* coordinatePredicate = [NSPredicate predicateWithFormat:@"longitude == %@ AND latitude == %@ ",[NSNumber numberWithDouble:longitude],[NSNumber numberWithDouble:latitude]];
    NSFetchRequest *pinsRequest = [NSFetchRequest fetchRequestWithEntityName:@"Pins"];
    pinsRequest.predicate = coordinatePredicate;
    NSArray* array = [self.managedObjectContext executeFetchRequest:pinsRequest error:nil];
    return [array firstObject];
}

- (NSArray*) getPinsWithUserID:(NSString*) userID{
    NSPredicate* idPredicate = [NSPredicate predicateWithFormat:@"userID == %@",userID];
    NSFetchRequest *pinsRequest = [NSFetchRequest fetchRequestWithEntityName:@"Pins"];
    pinsRequest.predicate = idPredicate;
    return [self.managedObjectContext executeFetchRequest:pinsRequest error:nil];
}

- (NSArray*) allPins{
    NSFetchRequest *pinsRequest = [NSFetchRequest fetchRequestWithEntityName:@"Pins"];
    [pinsRequest setReturnsObjectsAsFaults:NO];
    return [self.managedObjectContext executeFetchRequest:pinsRequest error:nil];
}

- (void) deletePin:(id<MKAnnotation>) pin{
    CLLocationCoordinate2D coordinates = [(id)pin coordinate];//find better solution
    Pins* pinToDelete = [self getCurrentPin:coordinates];
    [self.managedObjectContext deleteObject:pinToDelete];
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "RB.Roman_Bobelyuk_SimplePins" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Kir_Ter_SimplePin" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Kir_Ter_SimplePin.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
