//
//  MapViewController.m
//  Shutterbug
//
//  Created by CS193p Instructor.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "MapViewController.h"
#import "FlickrPhotoAnnotation.h"
#import "FlickrPlaceAnnotation.h"
#import "FlickrFetcher.h"
#import "ImagesViewController.h"
#import "LocationImagesViewController.h"
#import "PlacesViewController.h"
#import "FlickrAnnotation.h"

@interface MapViewController() <MKMapViewDelegate> 
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation MapViewController

@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize delegate = _delegate;

#pragma mark - Synchronize Model and View

- (void)updateMapView
{
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations) [self.mapView addAnnotations:self.annotations];
}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}

#pragma mark - MKMapViewDelegate

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([self.delegate isKindOfClass:[PlacesViewController class]]){
        ImagesViewController *holder = [[[[[(PlacesViewController *)self.delegate tabBarController ] viewControllers] lastObject] viewControllers] objectAtIndex:0];
        [segue.destinationViewController setup:[[sender annotation] place]];
        [segue.destinationViewController setStorage:holder];   
    }  else{
        [segue.destinationViewController setup:[[sender annotation] photo]];
    }
}

- (void)mapView:(MKMapView *)sender
        annotationView:(MKAnnotationView *)aView
        calloutAccessoryControlTapped:(UIControl *)control
{
    if(!self.splitViewController){
    [self.delegate prepareForSegueFromAnnotation:aView];
    if([self.delegate isKindOfClass:[PlacesViewController class]])
        [self performSegueWithIdentifier:@"MapToMap" sender:aView];
    else
        [self performSegueWithIdentifier:@"MapToPhoto" sender:aView];
    } else {
        [self.delegate prepareForSegueFromAnnotation:aView];
        if([self.delegate isKindOfClass:[PlacesViewController class]])
            [self performSegueWithIdentifier:@"MapToMap" sender:aView];
        else
            [[[self.splitViewController viewControllers] lastObject] setup:[(FlickrAnnotation *)aView.annotation item]];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.canShowCallout = YES;
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure]; 
    }
    
    aView.annotation = annotation;
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    
    return aView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
    dispatch_async(downloadQueue, ^{
        UIImage *image = [self.delegate mapViewController:self imageForAnnotation:aView.annotation];
        dispatch_async(dispatch_get_main_queue(), ^{
            [(UIImageView *)aView.leftCalloutAccessoryView setImage:image];
        });
    });
}

-(MKCoordinateRegion)getCoordinates
{
    CLLocationDegrees minLat, maxLat, minLong, maxLong;
    CLLocationDegrees holderLat, holderLong;
    minLat = 9999.99;
    minLong = 9999.99;
    maxLat = -9999.99;
    maxLong = -9999.99;
    
    if([self.annotations count] == 0)
    {
        MKCoordinateRegion rect;
        rect.center.latitude = 0;
        rect.center.longitude = 0;
        rect.span.latitudeDelta = 100;
        rect.span.longitudeDelta = 100;
        
        return rect;
    }
    
    if([[self.annotations objectAtIndex:0] isKindOfClass:[FlickrPhotoAnnotation class]]){
    for(FlickrPhotoAnnotation *obj in self.annotations){
        holderLat = [[obj.photo objectForKey:FLICKR_LATITUDE] doubleValue];
        holderLong = [[obj.photo objectForKey:FLICKR_LONGITUDE] doubleValue];
        
        if(holderLong > maxLong) maxLong = holderLong;
        if(holderLat > maxLat) maxLat = holderLat;
        if(holderLong < minLong) minLong = holderLong;
        if(holderLat < minLat) minLat = holderLat;
    }   
    } else{
        for(FlickrPlaceAnnotation *obj in self.annotations){
            holderLat = [[obj.place objectForKey:FLICKR_LATITUDE] doubleValue];
            holderLong = [[obj.place objectForKey:FLICKR_LONGITUDE] doubleValue];
            
            if(holderLong > maxLong) maxLong = holderLong;
            if(holderLat > maxLat) maxLat = holderLat;
            if(holderLong < minLong) minLong = holderLong;
            if(holderLat < minLat) minLat = holderLat;
        }     
    }
    MKCoordinateRegion rect;
    rect.center.latitude = (maxLat + minLat)/2.0;
    rect.center.longitude = (maxLong + minLong)/2.0;
    if([[self.annotations objectAtIndex:0] isKindOfClass:[FlickrPhotoAnnotation class]]){
        rect.span.latitudeDelta = (maxLat - minLat) * 1.3;
        rect.span.longitudeDelta = (maxLong - minLong) * 1.3;
    }   else {
        rect.span.latitudeDelta = (maxLat - minLat) * 1.1;
        rect.span.longitudeDelta = (maxLong - minLong) * 1.1;
    }
    
    if(rect.span.latitudeDelta == 0) rect.span.latitudeDelta = .1;
    if(rect.span.longitudeDelta == 0) rect.span.longitudeDelta = .1;
    
    return rect;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.mapView.region = [self getCoordinates];
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
}

#pragma mark - Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
