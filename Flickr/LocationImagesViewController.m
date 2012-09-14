//
//  LocationImagesViewController.m
//  Flickr
//
//  Created by Michael Overstreet on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LocationImagesViewController.h"
#import "FlickrFetcher.h"
#import "FlickrPhotoAnnotation.h"
#import "MapViewController.h"
#import "PictureViewController.h"

@interface LocationImagesViewController() <MapViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapButton;
@end

@implementation LocationImagesViewController

@synthesize mapButton = _mapButton;
@synthesize storage = _storage;
@synthesize photos = _photos;

-(NSArray *)photos
{
    if(!_photos) _photos = [[NSArray alloc] init];
    return _photos;
}

-(void)setPhotos:(NSArray *)photos
{
    _photos = photos;
}

- (NSArray *)mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.photos count]];
    for (NSDictionary *photo in self.photos){
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

-(void)setup:(NSDictionary *)dict
{
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    UIBarButtonItem *holder = self.mapButton;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    [spinner startAnimating];
    dispatch_async(downloadQueue, ^{
        self.photos = [FlickrFetcher photosInPlace:dict maxResults:50];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.isViewLoaded) [self.tableView reloadData];{
                [spinner stopAnimating];
                self.navigationItem.rightBarButtonItem = holder;
                id nextView = [[self.splitViewController viewControllers] objectAtIndex:1];
                if([nextView isKindOfClass:[MapViewController class]]){
                    MapViewController *mapVC = (MapViewController *)nextView;
                    mapVC.delegate = self;
                    mapVC.annotations = [self mapAnnotations];
                }
            }
        });
    });
    dispatch_release(downloadQueue);
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        //[self.tableView reloadData];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"did load");
    //[self.tableView reloadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setMapButton:nil];
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

#pragma mark - Table view data source

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}*/

- (NSString *)getMyDataForRow:(int)row inSection:(int)section
{
    NSDictionary *dict = [self.photos objectAtIndex:row];
    return [dict objectForKey:FLICKR_PHOTO_TITLE];
}

- (NSString *)getMySubtitleDataForRow:(int)row inSection:(int)section
{
    NSDictionary *dict = [self.photos objectAtIndex:row];
    return [dict valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //NSLog(@"count %i", [self.brain.locationImageList count]);
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    //NSLog(@"in cell");
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationImagesProtoCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self getMyDataForRow:indexPath.row inSection:indexPath.section];
    if(cell.textLabel.text){
    cell.detailTextLabel.text = [self getMySubtitleDataForRow:indexPath.row inSection:indexPath.section];
    } else {
        cell.textLabel.text = [self getMySubtitleDataForRow:indexPath.row inSection:indexPath.section];
        if(cell.textLabel.text == @"") cell.textLabel.text = @"Unknown";
    }
    
    return cell;
}

-(void)prepareForSegueFromAnnotation:(MKAnnotationView *)aView
{
    [self.storage storeViewedPicture:[(FlickrPhotoAnnotation *) aView.annotation photo]];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [[[self.splitViewController viewControllers] lastObject] setup:[self.photos objectAtIndex:[indexPath indexAtPosition:1]]];
    [self.storage storeViewedPicture:[self.photos objectAtIndex:[indexPath indexAtPosition:1]]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ToPhoto"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        [segue.destinationViewController setImageData:[self.photos objectAtIndex:indexPath.row]];
        //NSLog(@"%@ *** %@", [self.photos objectAtIndex:[indexPath indexAtPosition:1]], self.storage);
        [self.storage storeViewedPicture:[self.photos objectAtIndex:indexPath.row]];
    } else {
        id nextView = segue.destinationViewController;
        if([nextView isKindOfClass:[MapViewController class]]){
            MapViewController *mapVC = (MapViewController *)nextView;
            mapVC.delegate = self;
            mapVC.annotations = [self mapAnnotations];
        }
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
