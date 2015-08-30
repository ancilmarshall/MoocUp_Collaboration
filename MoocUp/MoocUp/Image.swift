//
//  Image.swift
//  MoocUp
//
//  Created by Ancil on 8/29/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import Foundation
import CoreData

class Image: NSManagedObject {

    @NSManaged var createdAt: NSDate
    @NSManaged var objectId: String
    @NSManaged var photoData: NSData
    @NSManaged var syncStatus: NSNumber
    @NSManaged var thumbnailData: NSData
    @NSManaged var updatedAt: NSDate
    @NSManaged var course: Course
    @NSManaged var university: University
    @NSManaged var instructor: Instructor
    @NSManaged var mooc: Mooc
    @NSManaged var category: Category

}
