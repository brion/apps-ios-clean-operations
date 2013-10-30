//  Created by Felix Mo on 2013-01-30.

#import <Foundation/Foundation.h>

@interface MWNetworkActivityIndicatorManager : NSObject

+ (MWNetworkActivityIndicatorManager *)sharedManager;

- (void)show;
- (void)hide;

@end
