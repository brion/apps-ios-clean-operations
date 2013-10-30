//
//  AppDelegate.m
//  apps-ios-clean-operations
//
//  Created by Monte Hurd on 10/30/13.
//  Copyright (c) 2013 Monte Hurd. All rights reserved.
//

#import "AppDelegate.h"




#import "NSURLRequest+DictionaryRequest.h"
#import "MWNetworkActivityIndicatorManager.h"

typedef enum {
    OP_LOGIN,
    OP_TOKEN,
    OP_NAME_CHECK,
    OP_UPLOAD
} NetworkOpTypes;

@interface AppDelegate(){
    NSOperationQueue *opQueue_;
}

@property (strong, nonatomic) MWNetworkActivityIndicatorManager *activityIndicatorManager;

@end











@implementation AppDelegate









-(void)opFinished:(NetworkOp *)op
{
    [[MWNetworkActivityIndicatorManager sharedManager] hide];

    if (op.tag == OP_LOGIN) {
        if (op.error) {
            NSLog(@"login no: error = %@", op.error);
        }else{
            NSLog(@"login yes: dataRetrieved = %@", [NSString stringWithCString:[op.dataRetrieved bytes] encoding:NSUTF8StringEncoding]);
            NSLog(@"login duration = %f", op.finishedTime - op.startedTime);
            
            NSError *error;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:op.dataRetrieved options:0 error:&error];
            NSLog(@"login JSON found %@", result);
        }
    }
}

-(void)opStarted:(NetworkOp *)op
{
    [[MWNetworkActivityIndicatorManager sharedManager] show];

    if (op.tag == OP_LOGIN) {
        NSLog(@"login started");
    }
}

-(void)opProgressed:(NetworkOp *)op
{
    if (op.tag == OP_LOGIN) {
        NSLog(@"login progress: bytesWritten = %@ bytesExpectedToWrite = %@", op.bytesWritten, op.bytesExpectedToWrite);
    }
}










- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    
    
    
    








self.activityIndicatorManager = [[MWNetworkActivityIndicatorManager alloc] init];

NSString *url = @"https://test.wikipedia.org/w/api.php";
//NSString *url = @"https://commons.wikimedia.org/w/api.php";

NSURLRequest *request = [NSURLRequest postRequestWithURL:[NSURL URLWithString:url]
     parameters:@{
              @"action": @"login",
              @"lgname": @"montehurd",
              @"lgpassword": @"asdfsdf",
              @"format": @"json"
          }
];

NetworkOp *loginOperation = [[NetworkOp alloc] initWithRequest:request];
loginOperation.tag = OP_LOGIN;
loginOperation.delegate = self;



/*
NetworkOp *loginOperationWithToken = [[NetworkOp alloc] initWithRequest:request];
loginOperationWithToken.tag = OP_TOKEN;
loginOperationWithToken.delegate = self;
*/



opQueue_ = [[NSOperationQueue alloc] init];
[opQueue_ addOperation:loginOperation];






    
    
    
    
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
