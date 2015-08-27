//
//  Image.h
//  MoocUp
//
//  Created by Ancil on 8/27/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Course;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSData * photoData;
@property (nonatomic, retain) NSData * thumbnailData;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * prerequisite;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) Course *course;

@end
