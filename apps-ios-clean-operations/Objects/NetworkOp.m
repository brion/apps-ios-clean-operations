//  Created by Monte Hurd on 10/26/13.

#import "NetworkOp.h"

@interface NetworkOp()

#pragma mark - Private properties

@property (nonatomic, assign, getter = isOperationStarted) BOOL operationStarted;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSURLRequest *request;
@property (strong, nonatomic) NSURLResponse *response;

@end

@implementation NetworkOp
{
    // In concurrent operations, we have to manage the operation's state
    BOOL executing_;
    BOOL finished_;
}

#pragma mark - Init / dealloc

-(id)initWithRequest:(NSURLRequest *)request
{
    self = [super init];
    if (self) {
        self.error = nil;
        self.connection = nil;
        self.request = nil;
        self.response = nil;
        self.dataRetrieved = [[NSMutableData alloc] init];
        self.request = request;
        self.finishedTime = 0;
        self.startedTime = 0;
        self.initializationTime = [NSDate timeIntervalSinceReferenceDate];
        _bytesWritten = nil;
        _bytesExpectedToWrite = nil;
        finished_ = NO;
        executing_ = NO;
    }
    return self;
}

-(void)dealloc
{
    // Easy check to see if this operation is cleaned up when its work it done
    NSLog(@"DEALLOC'ED");
}

#pragma mark - Overrides required for concurrency

/*
    If you are creating a concurrent operation, you need to override the following methods at a minimum:
        start
        isConcurrent
        isExecuting
        isFinished
*/

-(void)start
{
    [self setOperationStarted:YES];  // See: http://stackoverflow.com/a/8152855/135557
	
    if(finished_ || [self isCancelled]) {
		[self finishWithError];
		return;
	}

    @autoreleasepool {
        
        self.startedTime = [NSDate timeIntervalSinceReferenceDate];
        
        // The autoreleasepool is needed to keep the thread from exiting before NSURLConnection finishes
        // See: http://stackoverflow.com/q/1728631/135557 for more info
        
        // From this point on, the operation is officially executing--remember, isExecuting
        // needs to be KVO compliant!
        [self willChangeValueForKey:@"isExecuting"];
        executing_ = YES;
        [self didChangeValueForKey:@"isExecuting"];
        
        // Create the NSURLConnection. Could have done so in init, but delayed until now in case the
        // operation was never enqueued or was cancelled before starting

        self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
        //NSLog(@"self.request.HTTPBody = %@", [NSString stringWithCString:[self.request.HTTPBody bytes] encoding:NSUTF8StringEncoding]);

        CFRunLoopRun(); // Avoid thread exiting
    }
}

-(BOOL)isExecuting
{
	return executing_;
}

-(BOOL)isFinished
{
	return finished_;
}

-(BOOL)isConcurrent
{
	return YES;
}

#pragma mark - Finishers

-(void)finish
{
    if (![self isOperationStarted]) return;

    self.finishedTime = [NSDate timeIntervalSinceReferenceDate];

    if(self.connection) {
        [self.connection cancel];
        // Don't nil self.connection here - it needs to call its delegates to wrap things up
    }

    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(opFinished:) withObject:self waitUntilDone:NO];

	// Alert anyone that we are finished
	[self willChangeValueForKey:@"isExecuting"];
	[self willChangeValueForKey:@"isFinished"];
	executing_ = NO;
	finished_  = YES;
	[self didChangeValueForKey:@"isFinished"];
	[self didChangeValueForKey:@"isExecuting"];    
}

-(void)finishWithError
{
	// Code for being cancelled    
    self.error = [[NSError alloc] initWithDomain:@"NetworkOp.m"
                                      code:555
                                  userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Op Cancelled.", nil)}];
	[self finish];
}

#pragma mark - NSURLConnectionDataDelegate methods

-(void)connection:(NSURLConnection*) connection didReceiveResponse:(NSURLResponse *)response
{
    self.response = response;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if([self isCancelled]) {
        [self finishWithError];
    }else{
        [self finish];
    }
}

-(void)connection:(NSURLConnection*) connection didReceiveData:(NSData *)data
{
    if([self isCancelled]) {
        [self finishWithError];
    }else{
        [self.dataRetrieved appendData: data];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.error = error;
    [self finish];
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    self.bytesWritten = [NSNumber numberWithInteger:totalBytesWritten];
    self.bytesExpectedToWrite = [NSNumber numberWithInteger:totalBytesExpectedToWrite];
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(opProgressed:) withObject:self waitUntilDone:NO];
}

@end
