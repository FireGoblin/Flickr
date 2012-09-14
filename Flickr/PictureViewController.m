//
//  PictureViewController.m
//  Flickr
//
//  Created by Michael Overstreet on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PictureViewController.h"
#import "FlickrFetcher.h"
#import "VacationHelper.h"
#import "Photo.h"
#import "Photo+Flickr.h"

@interface PictureViewController() <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) NSFileManager *manager;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *visitButton;
@property (nonatomic, strong) UIManagedDocument *photoDatabase;
@end

@implementation PictureViewController

@synthesize imageData = _imageData;
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize spinner = _spinner;
@synthesize manager = _manager;
@synthesize visitButton = _visitButton;
@synthesize image = _image;
@synthesize photoDatabase = _photoDatabase;

- (IBAction)visitPressed:(id)sender {
    if([self.visitButton.title isEqualToString:@"Visit"]){
            [Photo photoWithFlickrInfo:self.imageData inManagedObjectContext:self.photoDatabase.managedObjectContext];
        self.visitButton.title = @"Unvisit";
    } else {
        if(self.imageData){
        [Photo deletePhotoWithFlickrInfo:self.imageData inManagedObjectContext:self.photoDatabase.managedObjectContext];
            self.visitButton.title = @"Visit";
        } else {
            [Photo deletePhotoWithImageURL:self.image inManagedObjectContext:self.photoDatabase.managedObjectContext];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

-(NSFileManager *)manager
{
    if(!_manager) _manager = [NSFileManager defaultManager];
    return _manager;
}

-(void)setup:(NSDictionary *)picture
{
        [self.spinner startAnimating];
        dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
        dispatch_async(downloadQueue, ^{
            
            NSString *path = [[[self.manager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject] path];
            path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [self.imageData objectForKey:FLICKR_PHOTO_ID]]];
            NSData *dataholder;
            
            if([self.manager fileExistsAtPath:path]){
                NSLog(@"photo exists %@", path);
                dataholder = [self.manager contentsAtPath:path];
            } else{
                NSLog(@"photo doesn't exist %@", path);
                NSURL *urlholder = [FlickrFetcher urlForPhoto:self.imageData format:FlickrPhotoFormatLarge];
                dataholder = [NSData dataWithContentsOfURL:urlholder];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = [UIImage imageWithData:dataholder];
                self.title = [self.imageData objectForKey:FLICKR_PHOTO_TITLE];
                self.scrollView.delegate = self;
                self.scrollView.contentSize = self.imageView.image.size;
                self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
                CGFloat xFactor = CGRectGetMaxX(self.scrollView.bounds)/self.imageView.image.size.width;
                CGFloat yFactor = CGRectGetMaxY(self.scrollView.bounds)/self.imageView.image.size.height;
                if(xFactor >= yFactor) self.scrollView.zoomScale = xFactor;
                else    self.scrollView.zoomScale = yFactor;
                [self.spinner stopAnimating];
            });
        });
        dispatch_release(downloadQueue);
    
    if([Photo photoExistsWithFlickrInfo:self.imageData inManagedObjectContext:self.photoDatabase.managedObjectContext])
        self.visitButton.title = @"Unvisit";
    else
        self.visitButton.title = @"Visit";
}

-(void)setup
{
        [self.spinner startAnimating];
        dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
        dispatch_async(downloadQueue, ^{
            
            NSURL *url = self.image;
            NSData *dataholder;
            
            if([self.manager fileExistsAtPath:[url path]]){
                dataholder = [self.manager contentsAtPath:[url path]];
            } else{
                dataholder = [NSData dataWithContentsOfURL:self.image];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = [UIImage imageWithData:dataholder];
                self.scrollView.delegate = self;
                self.scrollView.contentSize = self.imageView.image.size;
                self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
                CGFloat xFactor = CGRectGetMaxX(self.scrollView.bounds)/self.imageView.image.size.width;
                CGFloat yFactor = CGRectGetMaxY(self.scrollView.bounds)/self.imageView.image.size.height;
                if(xFactor >= yFactor) self.scrollView.zoomScale = xFactor;
                else    self.scrollView.zoomScale = yFactor;
                [self.spinner stopAnimating];
            });
        });
        dispatch_release(downloadQueue);
    
    self.visitButton.title = @"Unvisit";
}
 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [VacationHelper openVacation:@"My Vacation" usingBlock:^(UIManagedDocument *doc){
        self.photoDatabase = doc;
    if(self.imageData)
        [self setup:self.imageData];
    else
        [self setup];
    }];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setImageView:nil];
    [self setSpinner:nil];
    [self setSpinner:nil];
    [self setSpinner:nil];
    [self setVisitButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
