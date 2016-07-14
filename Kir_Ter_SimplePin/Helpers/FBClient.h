//
//  FBClient.h
//  Kir_Ter_SimplePin
//
//  Created by Admin on 7/14/16.
//  Copyright © 2016 KirillTer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBClient : NSObject

@property (strong, nonatomic) NSString* currentAccesToken;
@property (strong, nonatomic) NSString* currentUserID;

+ (FBClient*) currentClient;
- (void) loggOut:(void(^)(void)) succesHandler;
- (void) getUserID:(void(^)(BOOL tokenValid)) succesHandler;

@end
