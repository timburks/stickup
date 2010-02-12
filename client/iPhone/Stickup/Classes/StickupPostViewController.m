//
//  StickupPostViewController.m
//  Stickup
//
//  Created by Tim Burks on 2/11/10.
//  Copyright 2010 Neon Design Technology, Inc. All rights reserved.
//

#import "StickupPostViewController.h"
#import "StickupAppDelegate.h"
#import "Helpers.h"
#import "APIController.h"

@interface FormTextField : UITextField {
	id form;
	id item;
}
@property (nonatomic, retain) id form;
@property (nonatomic, retain) id item;
@end

@implementation FormTextField
@synthesize form, item;

- (id) initWithFrame:(CGRect) frame form:(id) _form item:(id) _item {
	self = [super initWithFrame:frame];
	self.form = _form;
	self.item = _item;
	self.returnKeyType = UIReturnKeyDone;
	self.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.autocorrectionType = UITextAutocorrectionTypeNo;
	self.keyboardAppearance = UIKeyboardAppearanceAlert;
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	return self;
}

- (void) dealloc {
	[form release];
	[item release];
	[super dealloc];
}

static FormTextField *currentTextField = nil;

+ (FormTextField *) currentTextField {
	return currentTextField;
}

- (BOOL) becomeFirstResponder {
	[self retain];
	[currentTextField release];
	currentTextField = self;
	return [super becomeFirstResponder];
}

- (BOOL) resignFirstResponder {
	[form setObject:self.text forKey:item];
	return [super resignFirstResponder];
}

@end

@implementation StickupPostViewController

@synthesize info;
@synthesize postAPIController;

- (id) init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	self.info = [NSMutableDictionary dictionary];
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = @"Post a Stickup";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (section == 0) ? 3 : 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int section = [indexPath section];
	
	switch (section) {
		case 0: {
			int row = [indexPath row];
			switch (row) {
				case 0: {
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Username"];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Username"] autorelease];
						cell.selectionStyle = UITableViewCellSelectionStyleNone;
						cell.textLabel.text = @"Username";
						FormTextField *textField = [[[FormTextField alloc] 
													 initWithFrame:CGRectMake(100,5,200,30) form:self.info item:@"user"] 
													autorelease];
						textField.delegate = self;
						[cell addSubview:textField];
					}
					return cell;
				}
				case 1: {
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Password"];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Password"] autorelease];
						cell.selectionStyle = UITableViewCellSelectionStyleNone;
						cell.textLabel.text = @"Password";
						FormTextField *textField = [[[FormTextField alloc] 
													 initWithFrame:CGRectMake(100,5,200,30) form:self.info item:@"password"]
													autorelease];
						textField.delegate = self;
						textField.secureTextEntry = YES;
						[cell addSubview:textField];
					}
					return cell;
				}
				case 2: {
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Message"];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Message"] autorelease];
						cell.selectionStyle = UITableViewCellSelectionStyleNone;
						cell.textLabel.text = @"Message";
						FormTextField *textField = [[[FormTextField alloc] 
													 initWithFrame:CGRectMake(100,5,200,30) form:self.info item:@"message"] 
													autorelease];
						textField.delegate = self;
						[cell addSubview:textField];
					}
					return cell;
				}
				default:
					return nil;
			}
		}
		case 1: {
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Post"];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Post"] autorelease];
				cell.textLabel.text = @"Post this Stickup";
				cell.textLabel.textAlignment = UITextAlignmentCenter;
			}
			return cell;
		}
		default:
			return 0;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if ([indexPath section] == 1) {
		StickupAppDelegate *appDelegate = (StickupAppDelegate *) [[UIApplication sharedApplication] delegate];
		
		[[FormTextField currentTextField] resignFirstResponder];
		// add our location to the info dictionary
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
			[self.info setObject:[NSNumber numberWithFloat:coordinate.latitude] forKey:@"latitude"];
			[self.info setObject:[NSNumber numberWithFloat:coordinate.longitude] forKey:@"longitude"];
			// post the stickup			
			NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/stickup", appDelegate.server]];
			NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
			[request setHTTPMethod:@"POST"];
			[request setHTTPBody:[[self.info urlQueryString] dataUsingEncoding:NSUTF8StringEncoding]];
			
			if (!self.postAPIController)
				self.postAPIController = [[[APIController alloc] init] autorelease];
			
			[self.postAPIController connectWithRequest:request target:self selector:@selector(finishPost:)];
			
		}
	}
}

- (void) finishPost:(NSString *) resultString {
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
			[self.navigationController popViewControllerAnimated:YES];
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

#pragma mark textfield cellview support methods

- (BOOL) textFieldShouldReturn:(UITextField *) textField {
	[textField resignFirstResponder];
	return NO;
}

- (void)dealloc {
	[info release];
	[super dealloc];
}


@end

