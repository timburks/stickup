#import <Nunja/Nunja.h>
#import "NuMongoDB.h"
#import "JSON.h"

@interface ServerDelegate : NunjaDefaultDelegate 
{
}
@end

@implementation ServerDelegate

- (void) applicationDidFinishLaunching {
	
    [self addHandlerWithHTTPMethod:@"GET"
                            path:@"/"
                             block:^(NunjaRequest *REQUEST) {
                                 NSString *result = @"This is stickup.";
								 [REQUEST setContentType:@"text/plain"];
								 return result;                                 
                             }];
     
	[self addHandlerWithHTTPMethod:@"GET"
							  path:@"/pwd"
							 block:^(NunjaRequest *REQUEST) {
								 NSMutableString *result = [NSMutableString string];
								 [result appendString:[[NSFileManager defaultManager] currentDirectoryPath]];
								 [REQUEST setContentType:@"text/plain"];
								 return result;
							 }];
	
	[self addHandlerWithHTTPMethod:@"POST"
							  path:@"/reset"
							 block:^(NunjaRequest *REQUEST) {
								 NuMongoDB *mongo = [NuMongoDB new];
								 [mongo connectWithOptions:nil];								
								 [mongo authenticateUser:@"stickup" 
											withPassword:@"stickup" 
											 forDatabase:@"stickup"];
								 [mongo dropCollection:@"users" inDatabase:@"stickup"];
								 [mongo dropCollection:@"stickups" inDatabase:@"stickup"];
								 id result = [NSDictionary dictionaryWithObjectsAndKeys:
											  [NSNumber numberWithInt:200], @"status",
											  @"Reset database.", @"message",
											  nil];
								 [mongo close];
								 return [result JSONRepresentation];
							 }];
	
	[self addHandlerWithHTTPMethod:@"POST"
							  path:@"/stickup"
							 block:^(NunjaRequest *REQUEST) {
								 NuMongoDB *mongo = [NuMongoDB new];
								 [mongo connectWithOptions:nil];								
								 [mongo authenticateUser:@"stickup" 
											withPassword:@"stickup" 
											 forDatabase:@"stickup"];								 
								 id stickup = [REQUEST post];
								 id user = [mongo findOne:[NSDictionary dictionaryWithObjectsAndKeys:
														   [stickup objectForKey:@"user"], @"name",
														   nil]
											 inCollection:@"stickup.users"];
								 if (!user) {
									 user = [NSDictionary dictionaryWithObjectsAndKeys:
											 [stickup objectForKey:@"user"], @"name",
											 [stickup objectForKey:@"user"], @"password",
											 nil];
									 [mongo insertObject:user intoCollection:@"stickup.users"];
								 }
								 id result;
								 if ([[user objectForKey:@"password"] isEqualToString:
									  [stickup objectForKey:@"password"]]) {										
									 [stickup removeObjectForKey:@"password"];
									 [stickup setObject:[NSDate date] forKey:@"time"];
									 NSNumber *latitude = [NSNumber numberWithFloat:
														   [[stickup objectForKey:@"latitude"] floatValue]];
									 NSNumber *longitude = [NSNumber numberWithFloat:
															[[stickup objectForKey:@"longitude"] floatValue]];
									 
									 [stickup setObject:[NSDictionary dictionaryWithObjectsAndKeys:
														 latitude, @"latitude",
														 longitude, @"longitude",
														 nil]
												 forKey:@"location"];
									 [stickup removeObjectForKey:@"latitude"];
									 [stickup removeObjectForKey:@"longitude"];
									 [mongo insertObject:stickup intoCollection:@"stickup.stickups"];
									 result = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithInt:200], @"status",
                                               @"Thank you.", @"message",
                                               stickup, @"saved",
                                               nil];
								 } else {
									 result = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithInt:403], @"status",
                                               @"Unable to post stickup.", @"message",													  
                                               nil];
								 }	
								 [mongo close];
								 return [result JSONRepresentation];										 
							 }];
	
	[self addHandlerWithHTTPMethod:@"GET"
							  path:@"/count"
							 block:^(NunjaRequest *REQUEST) {
								 NuMongoDB *mongo = [NuMongoDB new];
								 [mongo connectWithOptions:nil];								
								 [mongo authenticateUser:@"stickup" 
											withPassword:@"stickup" 
											 forDatabase:@"stickup"];	
								 int count = [mongo countWithCondition:nil inCollection:@"stickups" inDatabase:@"stickup"];
								 id result = [NSDictionary dictionaryWithObjectsAndKeys:
											  [NSNumber numberWithInt:count], @"count",
											  [NSNumber numberWithInt:200], @"status",
											  nil];
								 [mongo close];
								 return [result JSONRepresentation];
							 }];
	
	[self addHandlerWithHTTPMethod:@"GET"
							  path:@"/stickups"
							 block:^(NunjaRequest *REQUEST) {
								 NuMongoDB *mongo = [NuMongoDB new];
								 [mongo connectWithOptions:nil];								
								 [mongo authenticateUser:@"stickup" 
											withPassword:@"stickup" 
											 forDatabase:@"stickup"];	
								 [mongo ensureCollection:@"stickup.stickups" 
												hasIndex:[NSDictionary dictionaryWithObjectsAndKeys:
														  @"2d", @"location", 
														  nil]
											 withOptions:0];
								 NSMutableDictionary *query = [NSMutableDictionary dictionary];
								 NSNumber *latitude = [NSNumber numberWithFloat:
													   [[[REQUEST query] objectForKey:@"latitude"] floatValue]];
								 NSNumber *longitude = [NSNumber numberWithFloat:
														[[[REQUEST query] objectForKey:@"longitude"] floatValue]];
								 [query setObject:[NSDictionary dictionaryWithObjectsAndKeys:
												   [NSDictionary dictionaryWithObjectsAndKeys:
													latitude, @"latitude",
													longitude, @"longitude",
													nil],
												   @"$near",
												   nil]									
										   forKey:@"location"];
								 int count = [[[REQUEST query] objectForKey:@"count"] intValue];
								 if (count == 0) {
									 count = 10;
								 }
								 id stickups = [mongo findArray:query inCollection:@"stickup.stickups"
												returningFields:nil numberToReturn:count numberToSkip:0];
								 id result = [NSDictionary dictionaryWithObjectsAndKeys:
											  [NSNumber numberWithInt:200], @"status",
											  stickups, @"stickups",
											  nil];
								 [mongo close];
								 return [result JSONRepresentation];
							 }];
	
}
@end

int main (int argc, const char * argv[])
{
	return NunjaMain(argc, argv, @"ServerDelegate");
}
