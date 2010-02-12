//
//  MapAnnotation.m
//  Stickup
//
//  Created by Tim Burks on 2/11/10.
//  Copyright 2010 Neon Design Technology, Inc. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation
@synthesize coordinate;

+ (id)annotationWithDictionary:(NSMutableDictionary *)d {
	return [[[[self class] alloc] initWithDictionary:d] autorelease];
}

- (id)initWithDictionary:(NSMutableDictionary *)d {
	self = [super init];
	if(nil != self) {
		CLLocation *location = [[[CLLocation alloc] initWithLatitude:[[d objectForKey:@"latitude"] floatValue]
														   longitude:[[d objectForKey:@"longitude"] floatValue]] autorelease];
		self.coordinate = location.coordinate;
	}
	return self;
}

@end