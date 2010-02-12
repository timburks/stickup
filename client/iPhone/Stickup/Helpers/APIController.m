//
//  APIController.m
//

#import "APIController.h"

@implementation APIController
@synthesize apiData, apiStatusCode, apiConnection, apiErrorAlert;
@synthesize target, selector;

- (APIController *) init 
{
	self = [super init];
	isRunning = NO;
	return self;
}

- (BOOL) isRunning {
	return isRunning;
}

- (void) connectWithRequest:(NSMutableURLRequest *) request target:(id) t selector:(SEL) s
{
	if (isRunning)
		return;
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
	self.selector = s;
	self.target = t;
	self.apiConnection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
	if (apiConnection) {
		self.apiData = [NSMutableData data];
		self.apiStatusCode = 0;
	}
	isRunning = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
	self.apiStatusCode = [response statusCode];
    [self.apiData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[self.apiData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	self.apiConnection = nil;
    self.apiData = nil;
	if (isRunning)
		[target performSelector:selector withObject:nil];
	isRunning = NO;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	if (isRunning) {
		if (apiStatusCode == 200) {
			NSString *result = [[[NSString alloc] initWithData:apiData encoding:NSUTF8StringEncoding] autorelease];
			[target performSelector:selector withObject:result];
		} else {
			[target performSelector:selector withObject:nil];
		}
	}
	isRunning = NO;
	self.apiConnection = nil;
    self.apiData = nil;
}

- (void) cancel {
	if (isRunning) {
		isRunning = NO;
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		[apiConnection cancel];
	}
}

- (void)dealloc {	
	[self cancel];
	[apiData release];
	[apiConnection release];
	[apiErrorAlert release];
    [super dealloc];
}

@end

