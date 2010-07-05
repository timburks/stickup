//
//  StickupListViewController.m
//  Stickup
//
//  Created by Tim Burks on 2/11/10.
//  Copyright 2010 Neon Design Technology, Inc. All rights reserved.
//

#import "StickupListViewController.h"
#import "StickupAppDelegate.h"
#import "MapAnnotation.h"
#import "APIController.h"
#import "Helpers.h"
#import "JSON.h"

@interface StickupListViewController (private)
- (void) reload:(id)sender;
@end

@implementation StickupListViewController

@synthesize stickups;
@synthesize listAPIController;

- (id) init {
	return [self initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = @"Nearby Stickups";
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
											   initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
											   target:self
											   action:@selector(reload:)] 
											  autorelease];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark API call

- (void) viewWillAppear:(BOOL)animated {
	[self reload:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
	[listAPIController cancel]; 
}
   
- (void) reload:(id) sender {
	StickupAppDelegate *appDelegate = (StickupAppDelegate *) [[UIApplication sharedApplication] delegate];

	CLLocation *location = [[appDelegate locationManager] location];
	if (!location) {
		UIAlertView *alertView = [[[UIAlertView alloc]
								   initWithTitle:@"Location error"
								   message:@"We can't do this until we know our current location."
								   delegate:nil
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil] autorelease];
		[alertView show];
	} else {
		CLLocationCoordinate2D coordinate = location.coordinate;
		NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/stickups", appDelegate.server]];
		
		NSMutableDictionary *postDictionary = [NSMutableDictionary dictionary];
		[postDictionary setObject:[NSNumber numberWithFloat:coordinate.latitude] forKey:@"latitude"];
		[postDictionary setObject:[NSNumber numberWithFloat:coordinate.longitude] forKey:@"longitude"];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];	
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody:[[postDictionary urlQueryString] dataUsingEncoding:NSUTF8StringEncoding]];
		if (!self.listAPIController) {
			self.listAPIController = [[[APIController alloc] init] autorelease];		
		}
		[self.listAPIController connectWithRequest:request target:self selector:@selector(finishList:)];
	}
}

- (void) finishList:(NSString *) resultString {
	if (!resultString) {
		UIAlertView *alertView = [[[UIAlertView alloc]
								   initWithTitle:@"Network problem"
								   message:@"The connection to our server failed."
								   delegate:nil
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil] autorelease];
		[alertView show];
	} else {
		id result = [resultString JSONValue];
		NSLog(@"got result %@", [result description]);
		
		id status = [result objectForKey:@"status"];
		if ([status intValue] == 200) { // success
			self.stickups = [result objectForKey:@"stickups"];
			[self.tableView reloadData];
		} else {
			UIAlertView *alertView = [[[UIAlertView alloc]
									   initWithTitle:@"Problem"
									   message:[result objectForKey:@"message"]
									   delegate:nil
									   cancelButtonTitle:@"OK"
									   otherButtonTitles:nil] autorelease];
			[alertView show];			
		}
	}
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return stickups ? [stickups count] : 0;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	if (row == 0) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Map"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Map"] autorelease];
			CGRect mapFrame = CGRectMake(0,0,300,100);
			MKMapView *mapView = [[[MKMapView alloc] initWithFrame:CGRectInset(mapFrame, 5, 5)] autorelease];
			[cell.contentView addSubview:mapView];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			mapView.layer.cornerRadius = 10.0;
			mapView.userInteractionEnabled = NO;
			mapView.showsUserLocation = NO;
			mapView.delegate = self;
			mapView.tag = 100;
		}
		return cell;
	} else if (row == 1) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Message"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Message"] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textLabel.numberOfLines = 2;
			cell.textLabel.adjustsFontSizeToFitWidth = YES;
		}
		return cell;
	} else if (row == 2) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Info"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Info"] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textLabel.font = [UIFont italicSystemFontOfSize:14];
		}
		return cell;
	} else {
		return nil;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	if (row == 0) {
		return 100;
	} else if (row == 1) {
		return 60;
	} else {
		return 44;
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	int section = [indexPath section];	
	int row = [indexPath row];
	
	id stickup = [self.stickups objectAtIndex:section];
	switch (row) {
		case 0: {
			MKMapView *mapView = (MKMapView *) [cell viewWithTag:100];
			MKCoordinateRegion region;
			region.center.latitude = [[[stickup objectForKey:@"location"] objectForKey:@"latitude"] floatValue];
		    region.center.longitude = [[[stickup objectForKey:@"location"] objectForKey:@"longitude"] floatValue];
			region.span.latitudeDelta = 0.01;
			region.span.longitudeDelta = 0.01;
			[mapView setRegion:region animated:NO];
			[mapView removeAnnotations:mapView.annotations];
			[mapView addAnnotation:[MapAnnotation annotationWithDictionary:stickup]];
			break;
		}
		case 1: 
			cell.textLabel.text = [stickup objectForKey:@"message"];
			break;
		case 2:
			cell.textLabel.text = [NSString stringWithFormat:@"said %@", [stickup objectForKey:@"user"]];
			cell.detailTextLabel.text = [NSString stringWithFormat:@"at %@", [stickup objectForKey:@"time"]];
			break;
		default:
			// don't worry about it
			break;
	}
}

- (void)dealloc {
	[listAPIController cancel]; // because NSURLConnection retains its delegate, we explicitly cancel any active connection
	[listAPIController release];
	[stickups release];
    [super dealloc];
}


@end

