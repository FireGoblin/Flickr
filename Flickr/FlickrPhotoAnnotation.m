//
//  FlickrPhotoAnnotation.m
//  Shutterbug
//
//  Created by CS193p Instructor.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "FlickrPhotoAnnotation.h"
#import "FlickrFetcher.h"
#import "FlickrAnnotation.h"

@implementation FlickrPhotoAnnotation

@synthesize photo = _photo;

+ (FlickrPhotoAnnotation *)annotationForPhoto:(NSDictionary *)photo
{
    FlickrPhotoAnnotation *annotation = [[FlickrPhotoAnnotation alloc] init];
    annotation.photo = photo;
    return annotation;
}

- (NSDictionary *)item
{
    return self.photo;
}

#pragma mark - MKAnnotation

- (NSString *)title
{
    NSString *holder = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
    
    if(!holder){
        holder = [self.photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    }
    if(!holder){
        holder = @"Unknown";
    }
    
    return holder;
}

- (NSString *)subtitle
{
    if(![self title]) return @"";
    return [self.photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.photo objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.photo objectForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;
}

@end
