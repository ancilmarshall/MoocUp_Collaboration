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
    var university = [University]()
    var instructors = [Instructor]()

    //used setup the relationships
    var sessionIds:[Int]? = nil
    var universityIds:[Int]? = nil
    var categoryIds:[Int]? = nil
    var instructorIds:[Int]? = nil
    
}

class Mooc : Base {
    
    var website = String()
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
}

class User : Base
{
    var settings = [UserSettings]()
}

class UserSettings : Base
{
    var categories = [Category]()
}
class Instructor : Base
{
    var image = Image()
    var courses = [Course]()
    var sessions = [Session]()
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
    var instructors = [Instructor]()
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




