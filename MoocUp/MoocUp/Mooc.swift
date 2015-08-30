//
//  Mooc.swift
//  MoocUp
//
//  Created by Ancil on 8/29/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import Foundation
import CoreData

class Mooc: NSManagedObject {

    @NSManaged var objectId: String
    @NSManaged var name: String
    @NSManaged var website: String
    @NSManaged var createdAt: NSDate
    @NSManaged var syncStatus: NSNumber
    @NSManaged var updatedAt: NSDate
    @NSManaged var courses: NSSet
    @NSManaged var image: Image

}
