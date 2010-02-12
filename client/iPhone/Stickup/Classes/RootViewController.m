//
//  RootViewController.m
//  Stickup
//
//  Created by Tim Burks on 2/11/10.
//  Copyright Neon Design Technology, Inc. 2010. All rights reserved.
//

#import "RootViewController.h"


@implementation RootViewController


- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = @"Stickup";
 }


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


// Customize the number of rows in the table view.
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


/*
// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController animated:YES];
	// [anotherViewController release];
}
*/


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (MKAnnotationView *)mapView:(MKMapView *)mv 
            viewForAnnotation:(id <MKAnnotation>)_annotation {
	MKAnnotationView *view = nil;
	if(_annotation == mv.userLocation) {
		MKCoordinateRegion region;
		
		region.center = mv.userLocation.location.coordinate;
		region.span.latitudeDelta = 0.01;
		region.span.longitudeDelta = 0.01;
		
		[mv setRegion:region animated:YES];
	}
	return view;
}




- (void)dealloc {
    [super dealloc];
}


@end

