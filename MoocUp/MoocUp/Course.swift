//
//  Course.swift
//  MoocUp
//
//  Created by Ancil on 8/29/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import Foundation
import CoreData

class Course: NSManagedObject {

    @NSManaged var createdAt: NSDate
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var objectId: String
    @NSManaged var prerequisite: String
    @NSManaged var summary: String
    @NSManaged var syncStatus: NSNumber
    @NSManaged var targetAudience: String
    @NSManaged var updatedAt: NSDate
    @NSManaged var videoLink: String
    @NSManaged var workload: String
    @NSManaged var categories: NSSet
    @NSManaged var image: Image
    @NSManaged var languages: NSSet
    @NSManaged var universities: NSSet
    @NSManaged var instructors: NSSet
    @NSManaged var moocs: NSSet
    @NSManaged var sessions: NSSet

}
