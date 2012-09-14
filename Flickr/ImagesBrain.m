//
//  ImagesBrain.m
//  Flickr
//
//  Created by Michael Overstreet on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ImagesBrain.h"
#import "LocationImagesViewController.h"
#import "FlickrFetcher.h"

@interface ImagesBrain() <LocationImagesStorage>
@property (nonatomic, strong) NSMutableArray *theList;
@property (nonatomic, strong) NSUserDefaults *defaults;
@property (nonatomic, strong) NSMutableArray *fileSizes;
@property (nonatomic, strong) NSMutableArray *filePaths;
@property (nonatomic, strong) NSFileManager *manager;
@end

@implementation ImagesBrain

@synthesize theList = _theList;
@synthesize defaults = _defaults;
@synthesize fileSizes = _fileSizes;
@synthesize manager = _manager;
@synthesize filePaths = _filePaths;

#define MB 1048576


-(NSFileManager *)manager
{
    if (!_manager) _manager = [NSFileManager defaultManager];
    return _manager;
}

-(NSUserDefaults *)defaults
{
    if(!_defaults){
        //[NSUserDefaults resetStandardUserDefaults];
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    return _defaults;
}

-(NSMutableArray *)theList
{
    if(!_theList) _theList = [[NSMutableArray alloc] init];
    return _theList;
}

-(NSMutableArray *)fileSizes
{
    if(!_fileSizes) _fileSizes = [[NSMutableArray alloc] init];
    return _fileSizes;
}

-(NSMutableArray *)filePaths
{
    if(!_filePaths) _filePaths = [[NSMutableArray alloc] init];
    return _filePaths;
}

-(NSArray *)imageList
{
    return [_theList copy];
}

-(void)loadData
{
    if([self.theList count] == 0)
    {
        self.theList = [[self.defaults objectForKey:@"FlickrRecentPhotos"] mutableCopy];
        self.fileSizes = [[self.defaults objectForKey:@"FlickrRecentPhotosSizes"] mutableCopy];
        self.filePaths = [[self.defaults objectForKey:@"FlickrRecentPhotosPaths"] mutableCopy];
    }
}

-(void)deleteCacheToSize:(long long) size
{
    long long sum = 0;
    NSLog(@"array size %i", [self.fileSizes count]);
    for (id obj in self.fileSizes){
        sum += [obj longLongValue];
    }
    
    NSLog(@"sum before delete %lld", sum);
    
    while(sum > size){
        NSString *path = [self.filePaths lastObject];
        [self.manager removeItemAtPath:path error:nil];
        sum -= [[self.fileSizes lastObject] longLongValue];
        
        [self.fileSizes removeLastObject];
        [self.filePaths removeLastObject];
    }
    
    NSLog(@"sum after delete %lld", sum);
}

-(void)storeViewedPicture:(NSDictionary *)picture
{
    /*NSEnumerator *e = [self.theList objectEnumerator];
    NSDictionary *obj;
    while(obj = [e nextObject]){
        if([obj objectForKey:@"woeid"] == [picture objectForKey:@"woeid"])
            
    }*/
    
    if([self.theList count] == 0)
    {
        self.theList = [[self.defaults objectForKey:@"FlickrRecentPhotos"] mutableCopy];
        self.fileSizes = [[self.defaults objectForKey:@"FlickrRecentPhotosSizes"] mutableCopy];
        self.filePaths = [[self.defaults objectForKey:@"FlickrRecentPhotosPaths"] mutableCopy];
    }
    NSUInteger index = [self.theList indexOfObject:picture];
    [self.theList removeObject:picture];
    [self.theList insertObject:picture atIndex:0];
    
    while([self.theList count] > 20) [self.theList removeLastObject];
    
    [self.defaults setObject:self.theList forKey:@"FlickrRecentPhotos"];
    
    NSString *component = [NSString stringWithFormat:@"%@", [picture objectForKey:FLICKR_PHOTO_ID]];
    NSString *path = [[[self.manager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject] path];
    path = [path stringByAppendingPathComponent:component];
    index = [self.filePaths indexOfObject:path];
    
    if(index == NSNotFound){
        NSLog(@"Adding file %@", path);
        NSURL *urlholder = [FlickrFetcher urlForPhoto:picture format:FlickrPhotoFormatLarge];
        NSData *image = [NSData dataWithContentsOfURL:urlholder];
        
        [self.manager createFileAtPath:path contents:image attributes:nil];
        [self.filePaths insertObject:path atIndex:0];
        [self.fileSizes insertObject:[NSNumber numberWithLongLong:[[self.manager attributesOfItemAtPath:path error:nil] fileSize]]  atIndex:0];
        NSLog(@"%lld", [[self.manager attributesOfItemAtPath:path error:nil] fileSize]);
        [self deleteCacheToSize:10*MB];
    } else{
        NSLog(@"Already have %@", path);
        NSNumber *sizeHolder = [self.fileSizes objectAtIndex:index];
        
        [self.fileSizes removeObjectAtIndex:index];
        [self.filePaths removeObjectAtIndex:index];
        
        [self.fileSizes insertObject:sizeHolder atIndex:0];
        [self.filePaths insertObject:path atIndex:0];        
    }
    
    [self.defaults setObject:self.filePaths forKey:@"FlickrRecentPhotosPaths"];
    [self.defaults setObject:self.fileSizes forKey:@"FlickrRecentPhotosSizes"];
}

@end
