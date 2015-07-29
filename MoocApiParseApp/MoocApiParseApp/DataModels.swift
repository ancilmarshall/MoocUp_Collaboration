//
//  DataModels
//  MoocUpAdminApp
//
//  These models are a common set of data models for the MoocUpAdminApp and 
//  MoocUpClientApp. They should not contain any Parse classes so that the 
//  MoocUpClientApp does not need to convert Parse objects to desired objects
//
//  Created by Ancil on 7/24/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import Foundation
import Parse

class Base : NSObject {
    
    var id = Int()
    var name = String()
    var summary = String()
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let obj = object as? Base {
            return id == obj.id
        } else {
            assert(false, "Exected instance of Base class during equality comparison")
        }
    }
}

class Course : Base
{
    var targetAudience = String()
    var prerequisite = String()
    var workload = String()
    var videoLink = String()
    var groups = [String]() //not sure about this. Maybe a join table
    var image = Image()
    var moocs = [Mooc]()
    var languages = [Language]()
    var categories = [Category]()
    var followers = [User]()
    var universities = [University]()
    var instructors = [Instructor]()
    var sessions = [Session]()
}

class Mooc : Base {
    
    var website = String()
    var courses = [Course]()
}

class Language : Base {
    var language = String()
}

class Image : Base
{
    var photoData = NSData()
    var smallIconData = NSData()
    var largeIconData = NSData()
}

class Category : Base
{
    var moocCategoryName = String()
    var image = Image()
    var courses = [Course]()
}

class User : Base
{
    var settings = [UserSettings]()
    var location = Location()
}

class Location: Base
{
    var city = String()
    var state = String()
    var country = String()
    
}

class UserSettings : Base
{
    var categories = [Category]()
}
class Instructor : Base
{
    var image = Image()
    var courses = [Course]()
    var website = String()
    
    //test for Instructor equality based on the name
    override func isEqual(object: AnyObject?) -> Bool {
        if let obj = object as? Base {
            return name == obj.name
        } else {
            assert(false, "Exected instance of Base class during equality comparison")
        }
    }
}

class University : Base
{
    var website = String()
    var image = Image()
    var courses = [Course]()
}

class Session : Base
{
    var homeLink = String()
    var duration = String()
    var startDate = NSDate()
    var instructors = [Instructor]()
    var course = Course()
}

class Review: Base
{
    var rating = String()
}


// Activity Models

class FollowCourse {
    let fromUser: PFUser
    let toCourse: Course
    
    init(fromUser: PFUser, toCourse: Course){
        self.fromUser = fromUser
        self.toCourse = toCourse
    }
}










