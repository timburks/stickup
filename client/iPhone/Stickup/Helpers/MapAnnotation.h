//
//  MapAnnotation.h
//  Stickup
//
//  Created by Tim Burks on 2/11/10.
//  Copyright 2010 Neon Design Technology, Inc. All rights reserved.
//

@interface MapAnnotation : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
}
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
+ (MapAnnotation *) annotationWithDictionary:(NSMutableDictionary *) dictionary;
@end
