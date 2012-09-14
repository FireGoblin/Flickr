//
//  FlickrPlaceAnnotation.m
//  Flickr
//
//  Created by Michael Overstreet on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FlickrPlaceAnnotation.h"
#import "FlickrFetcher.h"
#import "FlickrAnnotation.h"

@implementation FlickrPlaceAnnotation

@synthesize place = _place;

+ (FlickrPlaceAnnotation *)annotationForPlace:(NSDictionary *)place
{
    FlickrPlaceAnnotation *annotation = [[FlickrPlaceAnnotation alloc] init];
    annotation.place = place;
    return annotation;
}

- (NSDictionary *) item
{
    return self.place;
}

#pragma mark - MKAnnotation

- (NSString *)title
{
    NSString *holder = [self.place objectForKey:FLICKR_PLACE_NAME];
    
    return [[holder componentsSeparatedByString:@", "] objectAtIndex:0];
}

- (NSString *)subtitle
{
    NSString *holder = [self.place objectForKey:FLICKR_PLACE_NAME];
    NSArray *substrings = [holder componentsSeparatedByString:@", "];
    
    holder = [substrings objectAtIndex:1];
    
    for(int i = 2; i < [substrings count]; i++){
        holder = [holder stringByAppendingString:@", "];
        holder = [holder stringByAppendingString:[substrings objectAtIndex:i]];
    }
    
    return holder;
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.place objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.place objectForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;
}

@end