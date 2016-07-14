//
//  FBClient.m
//  Kir_Ter_SimplePin
//
//  Created by Admin on 7/14/16.
//  Copyright © 2016 KirillTer. All rights reserved.
//

#import "FBClient.h"
#import "DBManager.h"

@implementation FBClient

+ (FBClient*) currentClient{
    static FBClient *currentClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentClient = [[FBClient alloc] init];
    });
    return currentClient;
}

- (void) getUserID:(void(^)(BOOL tokenValid)) succesHandler{
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSString* urlString = [NSString stringWithFormat:@"https://graph.facebook.com/debug_token?input_token=%@&access_token=%@",self.currentAccesToken,self.currentAccesToken];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        NSData *data = [[NSData alloc] initWithContentsOfURL:location];
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSDictionary* dataDict = [responseDictionary objectForKey:@"data"];
        NSLog(@"userID: %@", [dataDict valueForKey:@"user_id"]);
        self.currentUserID = [dataDict valueForKey:@"user_id"] ;
        BOOL tokenValid = [[dataDict valueForKey:@"is_valid"]boolValue];
        succesHandler(tokenValid);
    }];
    [task resume];
}

- (void) loggOut:(void(^)(void)) succesHandler{
    NSURLSession *session = [NSURLSession sharedSession];
    NSString* nextURL = @"https://www.facebook.com/dialog/oauth?client_id=1828425020719071&response_type=token&redirect_uri=https://www.vk.com";
    NSString* urlString = [NSString stringWithFormat:@"http://facebook.com/logout.php?next=%@&access_token=%@",nextURL,self.currentAccesToken];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSData *data = [[NSData alloc] initWithContentsOfURL:location];
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSDictionary* dataDict = [responseDictionary objectForKey:@"data"];
        NSLog(@"dictlogout" );
        succesHandler();
    }];
    [task resume];
    
}

@end
