//
//  FlickrSecondViewController.m
//  Flickr
//
//  Created by Michael Overstreet on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ImagesViewController.h"
#import "LocationImagesViewController.h"
#import "ImagesBrain.h"
#import "FlickrFetcher.h"
#import "MapViewController.h"
#import "FlickrPhotoAnnotation.h"
#import "PictureViewController.h"

@interface ImagesViewController() <MapViewControllerDelegate>
@property (nonatomic, strong) ImagesBrain *brain;
@end

@implementation ImagesViewController

@synthesize brain = _brain;

-(ImagesBrain *)brain
{
    if(!_brain) _brain = [[ImagesBrain alloc] init];
    return _brain;
}

-(void)storeViewedPicture:(NSDictionary *)picture
{
    [self.brain storeViewedPicture:picture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.brain loadData];
    [self.tableView reloadData];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
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

//---------------------------------
- (NSString *)getMyDataForRow:(int)row inSection:(int)section
{
    NSDictionary *dict = [self.brain.imageList objectAtIndex:row];
    return [dict objectForKey:FLICKR_PHOTO_TITLE];
}

- (NSString *)getMySubtitleDataForRow:(int)row inSection:(int)section
{
    NSDictionary *dict = [self.brain.imageList objectAtIndex:row];
    return [dict valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //NSLog(@"count %i", [self.brain.locationImageList count]);
    return [self.brain.imageList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    //NSLog(@"in cell");
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageProtoCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self getMyDataForRow:indexPath.row inSection:indexPath.section];
    if(cell.textLabel.text){
        cell.detailTextLabel.text = [self getMySubtitleDataForRow:indexPath.row inSection:indexPath.section];
    } else {
        cell.textLabel.text = [self getMySubtitleDataForRow:indexPath.row inSection:indexPath.section];
        if(!cell.textLabel.text) cell.textLabel.text = @"Unknown";
    }
    
    return cell;
}

- (NSArray *)mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.brain.imageList count]];
    for (NSDictionary *photo in self.brain.imageList){
        [annotations addObject:[FlickrPhotoAnnotation annotationForPhoto:photo]];
    }
    return annotations;
}

#pragma mark - MapViewControllerDelegate

- (UIImage *)mapViewController:(MapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation
{
    FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *)annotation;
    NSURL *url = [FlickrFetcher urlForPhoto:fpa.photo format:FlickrPhotoFormatSquare];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data ? [UIImage imageWithData:data] : nil;
}

-(void)prepareForSegueFromAnnotation:(MKAnnotationView *)aView
{
    [self storeViewedPicture:[(FlickrPhotoAnnotation *) aView.annotation photo]];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [[[self.splitViewController viewControllers] lastObject] setup:[self.brain.imageList objectAtIndex:indexPath.row]];
    [self storeViewedPicture:[self.brain.imageList objectAtIndex:indexPath.row]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{   
    if([segue.identifier isEqualToString:@"ToPhotoRecent"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        [segue.destinationViewController setImageData:[self.brain.imageList objectAtIndex:indexPath.row]];
        [self storeViewedPicture:[self.brain.imageList objectAtIndex:indexPath.row]];
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
