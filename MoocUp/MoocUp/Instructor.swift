//
//  Instructor.swift
//  MoocUp
//
//  Created by Ancil on 8/29/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import Foundation
import CoreData

class Instructor: NSManagedObject {

    @NSManaged var summary: String
    @NSManaged var website: String
    @NSManaged var createdAt: NSDate
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var objectId: String
    @NSManaged var updatedAt: NSDate
    @NSManaged var syncStatus: NSNumber
    @NSManaged var image: Image
    @NSManaged var courses: NSSet

}
