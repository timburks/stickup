//
//  StickupPostViewController.h
//  Stickup
//
//  Created by Tim Burks on 2/11/10.
//  Copyright 2010 Neon Design Technology, Inc. All rights reserved.
//
@class APIController;

@interface StickupPostViewController : UITableViewController <UITextFieldDelegate> {
	id info;
	APIController *postAPIController;
}
@property (nonatomic, retain) id info;
@property (nonatomic, retain) APIController *postAPIController;
@end
