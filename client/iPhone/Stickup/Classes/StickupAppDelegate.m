//
//  StickupAppDelegate.m
//  Stickup
//
//  Created by Tim Burks on 2/11/10.
//  Copyright Neon Design Technology, Inc. 2010. All rights reserved.
//

#import "StickupAppDelegate.h"
#import "RootViewController.h"


@implementation StickupAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize locationManager;

#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    // Override point for customization after app launch    
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
	
	
	[self startLocationTracking];
	
	
	return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
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

