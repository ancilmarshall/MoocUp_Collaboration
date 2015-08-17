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

let kImageSetNotificationName = "ImageSetNotificationName"
let kCourseImageSetNotificationName = "CourseImageSetNotificationName"
let kInstructorImageSetNotificationName = "InstructorImageSetNotificationName"
let kUniversityImageSetNotificationName = "UniversityImageSetNotificationName"
let kCategoryImageSetNotificationName = "CategoryImageSetNotificationName"

//MARK: - Base
class Base : NSObject {
    
    var id = String()
    var name = String()
    var summary = String()
    
    override init() {
        super.init()
    }
    
    init(object: PFObject) {
        
        if object.isFetched() {
            
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
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let obj = object as? Base {
            return name == obj.name
        } else {
            assert(false, "Exected instance of Base class during equality comparison")
        }
    }
}

//MARK: - Course
class Course : Base, ImageSetDelegateProtocol
{
    var prerequisite = String()
    var workload = String()
    var videoLink = String()
    var targetAudience = String()
    var image = Image()
    var moocs = [Mooc]()
    var languages = [Language]()
    var categories = [Category]()
    var universities = [University]()
    var instructors = [Instructor]()
    var sessions = [Session]()
    
    override init() {
        super.init()
    }
    
    override init(object: PFObject) {
        
        super.init(object: object)

        if object.isFetched() {
            
            if let prerequisite = object["prerequisite"] as? String {
                self.prerequisite = prerequisite
            }
            
            if let workload = object["workload"] as? String {
                self.workload = workload
            }
            
            if let videoLink = object["videoLink"] as? String {
                self.videoLink = videoLink
            }
            
            if let targetAudience = object["targetAudience"] as? String {
                self.targetAudience = targetAudience
            }
            
            if let image = object["image"] as? PFObject {
                Image(object: image, delegate: self)
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
            
            if let languages = object["languages"] as? [PFObject] {
                self.languages = languages.map{ Language(object: $0)}
            }
        }
    }
    
    func imageDownloadComplete(image: Image){
        self.image = image
        NSNotificationCenter.defaultCenter()
            .postNotificationName(kCourseImageSetNotificationName, object: self)
    }
    
}

//MARK: - Image

protocol ImageSetDelegateProtocol {
    func imageDownloadComplete(image: Image)
}


class Image : Base
{
    var photoData = NSData()
    var smallIconData = NSData()
    var largeIconData = NSData()
    
    var delegate:ImageSetDelegateProtocol?
    
    override init() {
        super.init()
    }

    override init(object: PFObject){
        super.init(object: object)
        
    }
    
    //Fully initialize the Image if passed in a PFObject argument, and a delegate
    convenience init(object:PFObject, delegate:ImageSetDelegateProtocol) {
        
        self.init(object:object)

        if object.isFetched() {
            
            self.delegate = delegate
            
            NSNotificationCenter.defaultCenter()
                .addObserver(self, selector: Selector("photoDownloaded:"), name: "PhotoSet", object: nil)
            
            getPhoto(object)
        }
        
    }
    
    func photoDownloaded(notification: NSNotification){
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "PhotoSet", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "largeIconDownloaded:", name: "LargeIconSet", object: nil)
        getLargeIcon(notification.object as! PFObject)
    }
    
    func largeIconDownloaded(notification: NSNotification){
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "LargeIconSet", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "smallIconDownloaded:", name: "SmallIconSet", object: nil)
        getSmallIcon(notification.object as! PFObject)
        
        
    }
    
    func smallIconDownloaded(notification: NSNotification){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "SmallIconSet", object: nil)
        if let delegate = delegate {
            delegate.imageDownloadComplete(self)
        }
    }
    
    func getPhoto(object: PFObject) {
        
        if let photoImageFile = object["photo"] as? PFFile {
            
            photoImageFile.getDataInBackgroundWithBlock {
                
                (data:NSData?, error:NSError?) in
                
                if error == nil {
                    
                    if let data = data {
                        self.photoData = data
                    } else {
                        println("")
                    }
                } else {
                    println("")
                }
                NSNotificationCenter.defaultCenter().postNotificationName("PhotoSet", object: object)
            }
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName("PhotoSet", object: object)
        }
    }
    
    func getLargeIcon(object: PFObject){
        
        if let largeIconImageFile = object["largeIcon"] as? PFFile {
            
            largeIconImageFile.getDataInBackgroundWithBlock{
                (data:NSData?, error:NSError?) in
                
                if error == nil{
                    
                    if let data = data {
                        self.largeIconData = data
                        NSNotificationCenter.defaultCenter().postNotificationName("LargeIconSet", object: object)
                    }
                }
            }
        }
    }
    
    func getSmallIcon(object: PFObject){
        
        if let smallIconImageFile = object["smallIcon"] as? PFFile {
            smallIconImageFile.getDataInBackgroundWithBlock{
                (data:NSData?, error:NSError?) in
                
                if error == nil {
                    
                    if let data = data {
                        self.smallIconData = data
                        NSNotificationCenter.defaultCenter().postNotificationName("SmallIconSet", object: object)

                    }
                }
            }
        }
    }

}




//MARK:- Category
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
        
        if object.isFetched() {
            
        }
        
        super.init(object: object)
        
        //TODO: update Image
        //TODO: passing another object to create courses, or a setter
        
    }
}

//MARK:- Instructor

class Instructor : Base
{
    var image = Image()
    var courses = [Course]()
    var website = String()
    
    override init() {
        super.init()
    }
    
    override init(object: PFObject) {
        
        super.init(object: object)
        
        if object.isFetched() {
            
            if let website = object["website"] as? String {
                self.website = website
            }
            
            if let imageObject = object["image"] as? PFObject {
                
                if imageObject.isFetched() {
                    //self.image = Image(object: imageObject)
                    NSNotificationCenter.defaultCenter().addObserver(
                        self, selector: Selector("imageSetNotification:"),
                        name: kInstructorImageSetNotificationName, object: self.image)

                }
            }
        }
        //TODO: passing another object to create courses, or a setter
    }
    
    func imageSetNotification(notification: NSNotification){
        
        assert(notification.name == kInstructorImageSetNotificationName,
            "Expected an InstructorImageSetNotification notification")
        assert(notification.object as! Image == self.image,
            "Expected notification object to be image attribute of my instance")
        
        NSNotificationCenter.defaultCenter()
            .postNotificationName(kInstructorImageSetNotificationName, object:self)
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter()
            .removeObserver(self, name: kInstructorImageSetNotificationName, object: self.image)
    }
    
}

//MARK: - University
class University : Base
{
    var website = String()
    var image = Image()
    var courses = [Course]()
    
    override init() {
        super.init()
    }
    
    override init(object: PFObject) {

        super.init(object: object)

        if object.isFetched() {
            
            if let website = object["website"] as? String {
                self.website = website
            }
            
            if let imageObject = object["image"] as? PFObject {
                
                if imageObject.isFetched() {
                    //self.image = Image(object: imageObject)
                    NSNotificationCenter.defaultCenter().addObserver(
                        self, selector: Selector("imageSetNotification:"),
                        name: kUniversityImageSetNotificationName, object: self.image)
                    
                }
            }
        }
        
        
        //TODO: update Image
        //TODO: passing another object to create courses, or a setter
        
    }
    
    func imageSetNotification(notification: NSNotification){
        
        assert(notification.name == kUniversityImageSetNotificationName,
            "Expected a UniversityImageSetNotification notification")
        assert(notification.object as! Image == self.image,
            "Expected notification object to be image attribute of my instance")
        
        NSNotificationCenter.defaultCenter()
            .postNotificationName(kUniversityImageSetNotificationName, object:self)
        
    }

}

//MARK: - Session
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
        
        if object.isFetched() {
            
            if let homeLink = object["homeLink"] as? String {
                self.homeLink = homeLink
            }
            
            if let duration = object["duration"] as? String {
                self.duration = duration
            }
            
            if let startDate = object["startDate"] as? NSDate {
                self.startDate = startDate
            }
            
        }
        super.init(object: object)
        
        //TODO: update instructors
        //TODO: passing another object to create courses, or a setter
    }
}

//MARK: - Mooc
class Mooc : Base {
    
    var website = String()
    var courses = [Course]()
    
    override init() {
        super.init()
    }
    
    override init(object: PFObject) {
        
        if object.isFetched() {
            
            if let website = object["website"] as? String {
                self.website = website
            }
        }
        super.init(object: object)
    }
}

//MARK:- Language
class Language : Base {
    
    override init() {
        super.init()
    }
    
    override init(object: PFObject) {
        super.init(object: object)
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

class Review: Base
{
    var rating = String()
}


extension PFObject {
    
    // Test if the PFObject has been completely fetched from the Parse server
    // In some cases, the object is not fetched along with it's parent object
    // if it's include key was not part of the parent's object query
    func isFetched() -> Bool {
        return createdAt != nil
    }
    
}









