//
//  FlickrFirstViewController.m
//  Flickr
//
//  Created by Michael Overstreet on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlacesViewController.h"
#import "PlacesBrain.h"
#import "FlickrFetcher.h"
#import "LocationImagesViewController.h"
#import "ImagesViewController.h"
#import "MapViewController.h"
#import "FlickrPlaceAnnotation.h"

@interface  PlacesViewController() <MapViewControllerDelegate>
@property (nonatomic, strong) PlacesBrain *brain;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapButton;
@end

@implementation PlacesViewController

@synthesize brain = _brain;
@synthesize mapButton = _mapButton;


-(PlacesBrain *)brain
{
    if(!_brain) _brain = [[PlacesBrain alloc] init];
    return _brain;
}

-(NSArray *)places
{
    return [self.brain.placeList copy];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (NSArray *)mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.brain.placeList count]];
    for (NSDictionary *place in self.brain.placeList){
        [annotations addObject:[FlickrPlaceAnnotation annotationForPlace:place]];
    }
    return annotations;
}

#pragma mark - MapViewControllerDelegate

- (UIImage *)mapViewController:(MapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation
{
    FlickrPlaceAnnotation *fpa = (FlickrPlaceAnnotation *)annotation;
    NSURL *url = [FlickrFetcher urlForPhoto:fpa.place format:FlickrPhotoFormatSquare];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data ? [UIImage imageWithData:data] : nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //self.tableView.dataSource = self;
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    UIBarButtonItem *holder = self.mapButton;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    [spinner startAnimating];    dispatch_async(downloadQueue, ^{
        if(!self.brain.placeList)
            self.brain.placeList = [FlickrFetcher topPlaces];
        dispatch_async(dispatch_get_main_queue(), ^{
        if(self.isViewLoaded)
            [self.tableView reloadData];
            [spinner stopAnimating];
            self.navigationItem.rightBarButtonItem = holder;
            id nextView = [[self.splitViewController viewControllers] objectAtIndex:1];
            if([nextView isKindOfClass:[MapViewController class]]){
                MapViewController *mapVC = (MapViewController *)nextView;
                mapVC.delegate = self;
                mapVC.annotations = [self mapAnnotations];
            }    
        });
    });
    dispatch_release(downloadQueue);
}

- (void)viewDidUnload
{
    [self setMapButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

//-----------------------------------

- (NSString *)getMyDataForRow:(int)row inSection:(int)section
{
    NSDictionary *dict = [self.brain.placeList objectAtIndex:row];
    NSString *holder = [dict objectForKey:FLICKR_PLACE_NAME];
    
    return [[holder componentsSeparatedByString:@", "] objectAtIndex:0];
}

- (NSString *)getMySubtitleDataForRow:(int)row inSection:(int)section
{
    NSDictionary *dict = [self.brain.placeList objectAtIndex:row];
    NSString *holder = [dict objectForKey:FLICKR_PLACE_NAME];
    NSArray *substrings = [holder componentsSeparatedByString:@", "];
    
    holder = [substrings objectAtIndex:1];
    
    for(int i = 2; i < [substrings count]; i++){
        holder = [holder stringByAppendingString:@", "];
        holder = [holder stringByAppendingString:[substrings objectAtIndex:i]];
    }
    
    return holder;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.brain.placeList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"placesProtoCell"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"placesProtoCell"];
    }
    cell.textLabel.text = [self getMyDataForRow:indexPath.row inSection:indexPath.section];
    cell.detailTextLabel.text = [self getMySubtitleDataForRow:indexPath.row inSection:indexPath.section];
    return cell;
}
//------------------------------------
-(void)prepareForSegueFromAnnotation:(MKAnnotationView *)aView
{
     //nothing
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PlaceToLocation"]){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSArray *tabs = self.tabBarController.viewControllers;
        ImagesViewController * holder;
        for(UIViewController *view in tabs){
            if([view isKindOfClass:[ImagesViewController class]]){
                holder = (ImagesViewController *) view;
            }
        }
        [segue.destinationViewController setup:[self.brain.placeList objectAtIndex:indexPath.row]];
        [segue.destinationViewController setStorage:holder];
    } else {
        id nextView = segue.destinationViewController;
        if([nextView isKindOfClass:[MapViewController class]]){
            MapViewController *mapVC = (MapViewController *)nextView;
            mapVC.delegate = self;
            mapVC.annotations = [self mapAnnotations];
        }    
    }
}

@end
