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
    
    var id = String()
    var name = String()
    var summary = String()
    
    override init() {
        id = String()
        name = String()
        summary = String()
        
        super.init()
    }
    
    init(object: PFObject) {
        
        if let id = object["id"] as? String {
            self.id = id
        }
        
        if let name = object["name"] as? String {
            self.name = name
        }
        
        if let summary = object["summary"] as? String {
            self.summary = summary
        }
        
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let obj = object as? Base {
            return name == obj.name
        } else {
            assert(false, "Exected instance of Base class during equality comparison")
        }
    }
}

class Course : Base
{
    var prerequisite = String()
    var workload = String()
    var videoLink = String()
    var groups = [String]() //not sure about this. Maybe a join table
    var image = Image()
    var moocs = [Mooc]()
    var languages = [Language]()
    var categories = [Category]()
    //var followers = [User]()
    var universities = [University]()
    var instructors = [Instructor]()
    var sessions = [Session]()
    
    var imageSet = false
    var initialized = false
    
    override init() {
        super.init()
    }
    
    override init(object: PFObject) {
        
        if let prerequisite = object["prerequisite"] as? String {
            self.prerequisite = prerequisite
        }
        
        if let workload = object["workload"] as? String {
            self.workload = workload
        }
        
        if let videoLink = object["videoLink"] as? String {
            self.videoLink = videoLink
        }
        
        if let image = object["iamge"] as? PFObject {
            self.image = Image(object: image)
        }
        
        if let moocs = object["moocs"] as? [PFObject] {
            self.moocs = moocs.map{ Mooc(object: $0)}
        }
        
        if let instructors = object["instructors"] as? [PFObject] {
            self.instructors = instructors.map{ Instructor(object: $0) }
        }
        
        if let universities = object["universities"] as? [PFObject] {
            self.universities = universities.map{ University(object: $0) }
        }
        
        if let sessions = object["sessions"] as? [PFObject] {
            self.sessions = sessions.map{ Session(object: $0) }
        }
        
        if let categories = object["categories"] as? [PFObject] {
            self.categories = categories.map{ Category(object: $0) }
        }
               
        super.init(object: object)
    }


    
}

class Mooc : Base {
    
    var website = String()
    var courses = [Course]()
    
    override init() {
        super.init()
    }
    
    override init(object: PFObject) {

        if let website = object["website"] as? String {
            self.website = website
        }
        
        // course?
        super.init(object: object)
    }
    
    
}

class Language : Base {
    var language = String()
}

class Image : Base
{
    var photoData = NSData()
    var smallIconData = NSData()
    var largeIconData = NSData()
    
    override init() {
        super.init()
    }
    
    override init(object: PFObject){
        
        super.init(object: object)
        
        if let imageObject = object["image"] as? PFObject {
            if let photoImageFile = imageObject["photo"] as? PFFile {
                photoImageFile.getDataInBackgroundWithBlock{ (data:NSData?, error:NSError?) in
                    if let data = data {
                        self.photoData = data
                    }
                }
            }
            
            if let smallIconImageFile = imageObject["smallIcon"] as? PFFile {
                smallIconImageFile.getDataInBackgroundWithBlock{ (data:NSData?, error:NSError?) -> Void in
                    
                    if let data = data {
                        self.smallIconData = data
                    }
                }
            }
            
            if let largeIconImageFile = imageObject["largeIcon"] as? PFFile {
                largeIconImageFile.getDataInBackgroundWithBlock{ (data:NSData?, error:NSError?) -> Void in
                    
                    if let data = data {
                        self.largeIconData = data
                    }
                }
            }
        }
        
    }
}

//TODO: Add a category image, by designing new graphics or using external resource
class Category : Base
{
    var moocCategoryName = String()
    var image = Image()
    var courses = [Course]()
    
    override init() {
        super.init()
    }
    
    override init(object: PFObject) {
        
        super.init(object: object)
        
        //TODO: update Image
        //TODO: passing another object to create courses, or a setter
        
    }
    
    
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

    override init() {
        super.init()
    }
    
    override init(object: PFObject) {
        
        if let website = object["website"] as? String {
            self.website = website
        }
        
        super.init(object: object)
        
        //TODO: update Image
        //TODO: passing another object to create courses, or a setter
        
    }
    
    
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
    
    override init() {
        super.init()
    }
    
    override init(object: PFObject) {
        
        if let website = object["website"] as? String {
            self.website = website
        }
        
        super.init(object: object)
        
        //TODO: update Image
        //TODO: passing another object to create courses, or a setter
        
    }
    
    
}

class Session : Base
{
    var homeLink = String()
    var duration = String()
    var startDate = NSDate()
    var instructors = [Instructor]()
    var course = Course()
    
    override init() {
        super.init()
    }

    override init(object: PFObject) {
        
        if let homeLink = object["homeLink"] as? String {
            self.homeLink = homeLink
        }
        
        if let duration = object["duration"] as? String {
            self.duration = duration
        }
        
        if let startDate = object["startDate"] as? NSDate {
            self.startDate = startDate
        }
        
        super.init(object: object)
        
        //TODO: update instructors
        //TODO: passing another object to create courses, or a setter
        
    }
    
    
}

class Review: Base
{
    var rating = String()
}












