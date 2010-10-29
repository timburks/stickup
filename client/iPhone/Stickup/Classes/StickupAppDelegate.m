//
//  StickupAppDelegate.m
//  Stickup
//
//  Created by Tim Burks on 2/11/10.
//  Copyright Neon Design Technology, Inc. 2010. All rights reserved.
//

#import "StickupAppDelegate.h"
#import "RootViewController.h"

@interface StickupAppDelegate (private)
- (void) startLocationTracking;
@end

@implementation StickupAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize locationManager;
@synthesize server;

#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {   
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
 	self.server = [defaults objectForKey:@"server_preference"];
	//if (!self.server) self.server = @"http://stickup-demo.appspot.com";

	if (!self.server) self.server = @"http://localhost:3000";
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
	[self startLocationTracking];
	return YES;
}

#pragma mark Location Tracking

- (void) startLocationTracking 
{
	self.locationManager = [[[CLLocationManager alloc] init] autorelease];
	[locationManager setDelegate:self];
	[locationManager setDistanceFilter:1]; 
	[locationManager startUpdatingLocation];
	[locationManager setDesiredAccuracy:kCLLocationAccuracyBest];	
}

- (CLLocation *) currentLocation {
	return self.locationManager.location;
}

#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[locationManager release];
	[super dealloc];
}

@end

