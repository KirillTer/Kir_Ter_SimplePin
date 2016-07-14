//
//  Pins+CoreDataProperties.h
//  Kir_Ter_SimplePin
//
//  Created by Admin on 7/14/16.
//  Copyright © 2016 KirillTer. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Pins.h"

NS_ASSUME_NONNULL_BEGIN

@interface Pins (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSString *userID;

@end

NS_ASSUME_NONNULL_END
