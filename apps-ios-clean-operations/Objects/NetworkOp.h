//  Created by Monte Hurd on 10/26/13.

#import <Foundation/Foundation.h>

@class NetworkOp;

@protocol NetworkOpDelegate <NSObject>
    -(void)opStarted:(NetworkOp *)op;
    -(void)opFinished:(NetworkOp *)op;
@optional
    -(void)opProgressed:(NetworkOp *)op;
@end

@interface NetworkOp : NSOperation <NSURLConnectionDataDelegate>

-(id)initWithRequest:(NSURLRequest *)request;

// Do not use strong for delegate or the operation will not be released properly 
@property (weak) id <NetworkOpDelegate> delegate;

@property (strong, nonatomic) NSNumber *bytesWritten;
@property (strong, nonatomic) NSNumber *bytesExpectedToWrite;

@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) NSMutableData *dataRetrieved;

@property (nonatomic) NSTimeInterval initializationTime;
@property (nonatomic) NSTimeInterval startedTime;
@property (nonatomic) NSTimeInterval finishedTime;

@property (nonatomic) NSUInteger tag;

@end

