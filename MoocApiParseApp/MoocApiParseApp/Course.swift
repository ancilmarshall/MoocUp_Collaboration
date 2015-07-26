//
//  MUCourse.swift
//  MoocApiParseApp
//
//  Created by Ancil on 7/24/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import Foundation
import Parse

class Course : NSObject
{
    //data memebers to be modeled in this class
    var id = Int()
    var name = String()
    var shortName = String()
    var mooc = String()
    var photo = String()
    var thumbnail = NSData()
    var language = String()
    var workload = String()
    var groups = [String]()
    var category = String()
    var followers = [User]()
    var university = [University]()
    var instructors = [Instructor]()

    //used setup the relationships
    var sessionIds:[Int]? = nil
    var universityIds:[Int]? = nil
    var categoryIds:[Int]? = nil
    var instructorIds:[Int]? = nil
}