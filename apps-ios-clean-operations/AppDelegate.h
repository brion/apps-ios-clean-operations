//
//  AppDelegate.h
//  apps-ios-clean-operations
//
//  Created by Monte Hurd on 10/30/13.
//  Copyright (c) 2013 Monte Hurd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkOp.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, NetworkOpDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
