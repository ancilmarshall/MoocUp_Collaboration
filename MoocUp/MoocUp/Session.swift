//
//  Session.swift
//  MoocUp
//
//  Created by Ancil on 8/29/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import Foundation
import CoreData

class Session: NSManagedObject {

    @NSManaged var objectId: String
    @NSManaged var syncStatus: NSNumber
    @NSManaged var duration: String
    @NSManaged var homeLink: String
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var createdAt: NSDate
    @NSManaged var updatedAt: NSDate
    @NSManaged var course: Course

}
