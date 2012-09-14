//
//  FlickrPhotoAnnotation.h
//  Flickr
//
//  Created by Michael Overstreet on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "FlickrAnnotation.h"

@interface FlickrPhotoAnnotation : FlickrAnnotation

+ (FlickrPhotoAnnotation *)annotationForPhoto:(NSDictionary *)photo;

- (NSDictionary *)item;

@property (nonatomic, strong) NSDictionary *photo;

@end
