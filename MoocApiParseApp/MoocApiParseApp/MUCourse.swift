//
//  MUCourse.swift
//  MoocApiParseApp
//
//  Created by Ancil on 7/24/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import Foundation
import Parse

class MUCourse
{
    var name: String = ""
    var shortName: String = ""
    var mooc: String = ""
    var photo:String = ""
    var thumbnail:NSData = NSData()
    var language: String = ""
    var workload: String = ""
    var groups:[String] = [String]()
    var category:String = ""
    var followers:[MUUser] = [MUUser]()
    var university:[MUUniversity] = [MUUniversity]()
    var instructors:[MUInstructor] = [MUInstructor]()
    
}