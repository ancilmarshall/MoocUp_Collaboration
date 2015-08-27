//
//  Course.h
//  MoocUp
//
//  Created by Ancil on 8/27/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Image;

@interface Course : NSManagedObject

@property (nonatomic, retain) NSString * prerequisite;
@property (nonatomic, retain) NSString * workload;
@property (nonatomic, retain) NSString * videoLink;
@property (nonatomic, retain) NSString * targetAudience;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) Image *image;

@end
