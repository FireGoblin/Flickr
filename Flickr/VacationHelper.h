//
//  VacationHelper.h
//  Flickr
//
//  Created by Michael Overstreet on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^completion_block_t)(UIManagedDocument *vacation);

@interface VacationHelper : NSObject

+ (void)openVacation:(NSString *)vacationName usingBlock:(completion_block_t)completionBlock;

@end
