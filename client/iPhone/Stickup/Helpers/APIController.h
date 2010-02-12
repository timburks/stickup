#import <Foundation/Foundation.h>

@interface APIController : NSObject
{
	NSMutableData *apiData;
	int apiStatusCode;
	NSConnection *apiConnection;
	UIAlertView *apiErrorAlert;
	id target;
	SEL selector;
	BOOL isRunning; // privately managed, so it's NOT a property.
}
@property (nonatomic, retain) NSMutableData *apiData;
@property (nonatomic, assign) int apiStatusCode;
@property (nonatomic, retain) NSConnection *apiConnection;
@property (nonatomic, retain) UIAlertView *apiErrorAlert;
@property (nonatomic, assign) id target;
@property SEL selector;

- (void) connectWithRequest:(NSMutableURLRequest *) request target:(id) targ selector:(SEL) sel;
- (BOOL) isRunning;
- (void) cancel;

@end