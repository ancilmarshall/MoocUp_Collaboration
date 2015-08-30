//
//  University.swift
//  MoocUp
//
//  Created by Ancil on 8/29/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import Foundation
import CoreData

class University: NSManagedObject {

    @NSManaged var createdAt: NSDate
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var objectId: String
    @NSManaged var summary: String
    @NSManaged var updatedAt: NSDate
    @NSManaged var website: String
    @NSManaged var syncStatus: NSNumber
    @NSManaged var courses: NSSet
    @NSManaged var image: Image

}
