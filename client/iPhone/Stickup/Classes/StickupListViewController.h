//
//  StickupListViewController.h
//  Stickup
//
//  Created by Tim Burks on 2/11/10.
//  Copyright 2010 Neon Design Technology, Inc. All rights reserved.
//
@class APIController;

@interface StickupListViewController : UITableViewController <MKMapViewDelegate> {
	id stickups;
	APIController *listAPIController;
}
@property (nonatomic, retain) id stickups;
@property (nonatomic, retain) APIController *listAPIController;
@end
