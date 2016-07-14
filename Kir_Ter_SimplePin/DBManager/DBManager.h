//
//  DBManager.h
//  Kir_Ter_SimplePin
//
//  Created by Admin on 7/14/16.
//  Copyright © 2016 KirillTer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import "Pins.h"


@interface DBManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (DBManager*) sharedManager;
- (Pins*) savePin:(CLLocationCoordinate2D) coordinates withUserID:(NSString*) userID;
- (Pins*) getCurrentPin:(CLLocationCoordinate2D) coordinates;
- (NSArray*) getPinsWithUserID:(NSString*) userID;
- (void) deletePin:(id<MKAnnotation>) pin;

- (void) saveContext;

@end
