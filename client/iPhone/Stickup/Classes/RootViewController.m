//
//  RootViewController.m
//  Stickup
//
//  Created by Tim Burks on 2/11/10.
//  Copyright Neon Design Technology, Inc. 2010. All rights reserved.
//

#import "RootViewController.h"
#import "StickupListViewController.h"
#import "StickupPostViewController.h"

@interface RootViewController (private)
- (void) recenterMapView:(MKMapView *) mv;
@end

@implementation RootViewController

#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = @"Stickup";
 }

- (void)dealloc {
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}

#pragma mark Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	int section = [indexPath section];	
	switch (section) {
		case 1:
			cell.textLabel.text = @"Nearby Stickups";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case 2:
			cell.textLabel.text = @"Post a Stickup";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		default:
			// don't worry about it
			break;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	int section = [indexPath section];	
	switch (section) {
		case 0: {
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Map"];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Map"] autorelease];
				CGRect mapFrame = CGRectMake(0,0,300,200);
				MKMapView *mapView = [[[MKMapView alloc] initWithFrame:CGRectInset(mapFrame, 5, 5)] autorelease];
				[cell.contentView addSubview:mapView];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				mapView.layer.cornerRadius = 10.0;
				mapView.userInteractionEnabled = NO;
				mapView.showsUserLocation = YES;
				mapView.delegate = self;
				mapView.tag = 100;
			}
			return cell;
		}
		default: {
			static NSString *CellIdentifier = @"Cell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
			return cell;
		}
	}
 }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	int section = [indexPath section];
	
	switch (section) {
		case 0: 
			return 200;
		default: 
			return 40;
	}
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int section = [indexPath section];
	
	switch (section) {
		case 0: {
			MKMapView *mapView = (MKMapView *) [[tableView cellForRowAtIndexPath:indexPath] viewWithTag:100];
			[self recenterMapView:mapView];
			break;
		}
		case 1: {
			StickupListViewController *stickupListViewController = [[[StickupListViewController alloc] init] autorelease];
			[self.navigationController pushViewController:stickupListViewController animated:YES];
			break;
		}
		case 2: {
			StickupPostViewController *stickupPostViewController = [[[StickupPostViewController alloc] init] autorelease];
			[self.navigationController pushViewController:stickupPostViewController animated:YES];
			break;
		}
		default:
			break;
	}
}

#pragma mark Map

- (MKAnnotationView *)mapView:(MKMapView *)mv 
            viewForAnnotation:(id <MKAnnotation>)_annotation {
	MKAnnotationView *view = nil;
	if(_annotation == mv.userLocation) {
		[self recenterMapView:mv];
	}
	return view;
}

- (void) recenterMapView:(MKMapView *) mv {
	MKCoordinateRegion region;
	region.center = mv.userLocation.location.coordinate;
	region.span.latitudeDelta = 0.01;
	region.span.longitudeDelta = 0.01;
	[mv setRegion:region animated:YES];
}

@end

