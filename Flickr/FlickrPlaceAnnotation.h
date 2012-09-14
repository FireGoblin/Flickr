//
//  FlickrPlaceAnnotation.h
//  Flickr
//
//  Created by Michael Overstreet on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "FlickrAnnotation.h"

@interface FlickrPlaceAnnotation : FlickrAnnotation

+ (FlickrPlaceAnnotation *)annotationForPlace:(NSDictionary *)place;

- (NSDictionary *)item;

@property (nonatomic, strong) NSDictionary *place;

@end
