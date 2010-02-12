//
//  StickupPostViewController.m
//  Stickup
//
//  Created by Tim Burks on 2/11/10.
//  Copyright 2010 Neon Design Technology, Inc. All rights reserved.
//

#import "StickupPostViewController.h"

@interface FormTextField : UITextField {
}
@end

@implementation FormTextField

- (id) initWithFrame:(CGRect) frame {
	self = [super initWithFrame:frame];
	self.returnKeyType = UIReturnKeyDone;
	self.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.autocorrectionType = UITextAutocorrectionTypeNo;
	self.keyboardAppearance = UIKeyboardAppearanceAlert;
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	return self;
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

@end


@implementation StickupPostViewController

- (id) init {
	return [self initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = @"Post a Stickup";
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
						FormTextField *textField = [[[FormTextField alloc] initWithFrame:CGRectMake(100,5,200,30)] autorelease];
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
						FormTextField *textField = [[[FormTextField alloc] initWithFrame:CGRectMake(100,5,200,30)] autorelease];
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
						FormTextField *textField = [[[FormTextField alloc] initWithFrame:CGRectMake(100,5,200,30)] autorelease];
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
		// post the stickup
		[[FormTextField currentTextField] resignFirstResponder];
		// [self.navigationController popViewControllerAnimated:YES];
	}
}

#pragma mark textfield cellview support methods

- (BOOL) textFieldShouldReturn:(UITextField *) textField {
	[textField resignFirstResponder];
	return NO;
}

- (void)dealloc {
	[super dealloc];
}


@end

