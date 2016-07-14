//
//  SignInViewController.m
//  Kir_Ter_SimplePin
//
//  Created by Admin on 7/14/16.
//  Copyright © 2016 KirillTer. All rights reserved.
//

#import "SignInViewController.h"
#import "FBClient.h"
// http://facebook.com/logout.php?next=YOUR_NEXT_URL_FOR_LOGOUT&access_token=USER_TOKEN


NSString* logInURL = @"https://www.facebook.com/dialog/oauth?client_id=1828425020719071&response_type=token&redirect_uri=https://www.vk.com";

@interface SignInViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButtonAction;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated{
    self.webView.hidden = YES;
    self.loginButton.hidden = NO;
}

#pragma mark -- UIWebViewDelegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error{
    NSLog(@"%@", error);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString* requestString =request.URL.absoluteString;
    
    if([requestString containsString:@"access_token"]){
        NSString* currentToken = [self getAccesTokenFromURL:requestString];
        NSLog(@"finalToken = %@",currentToken);
        [FBClient currentClient].currentAccesToken = currentToken;
        [webView stopLoading];
        __weak SignInViewController* weakSelf = self;
        [[FBClient currentClient] getUserID:^(BOOL tokenValid) {
            if (tokenValid) {
                NSLog(@"succes");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf performSegueWithIdentifier:@"showMap" sender:nil];
                });
            }else{
                [self loginButtonAction:self.loginButton];
            }
        }];
    }
    return YES;
}

#pragma mark -- Helped Methods

- (NSString*) getAccesTokenFromURL:(NSString*) urlString{
    NSString* tmpString = [[urlString componentsSeparatedByString:@"&"]firstObject];
    NSString* anotherString = [[tmpString componentsSeparatedByString:@"#"]lastObject];
    NSString* finalToken = [[anotherString componentsSeparatedByString:@"="]lastObject];
    return finalToken;
}

#pragma mark - actions

- (IBAction)loginButtonAction:(UIButton *)sender {
    sender.hidden = YES;
    self.webView.hidden = NO;
    self.webView.delegate = self;
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:logInURL]];
    [self.webView loadRequest:request];
}

@end
