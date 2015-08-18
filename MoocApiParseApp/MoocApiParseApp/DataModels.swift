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

let kCourseCompleteNotificationName = "CourseImageSetNotificationName"

//MARK: - Base
class Base : NSObject {
    
    var id = String()
    var name = String()
    var summary = String()
    
    override init() {
        super.init()
    }
    
    init(object: PFObject) {
        
        if object.isIncluded() {
            
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
class Course : Base, ImageSetDelegateProtocol, InstructorSetDelegateProtocol,
    UniversitySetDelegateProtocol
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

        if object.isIncluded() {
            
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
            
            if let instructorObjects = object["instructors"] as? [PFObject] {
                self.instructorObjects = instructorObjects
                totalInstructors = instructorObjects.count
            }
            
            if let universityObjects = object["universities"] as? [PFObject] {
                self.universityObjects = universityObjects
                totalUniversities = universityObjects.count
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
    
    //Notice the chain of initializations, which is needed to download images
    // 1 Image ( i.e. Course.image)
    // 2 Instructor
    // 3 University
    func imageDownloadComplete(image: Image){
        self.image = image
        getNextInstructor()
    }
    
    // Handle Instructors Initialization
    var totalInstructors = 0
    var currentInstructor = 0
    var instructorObjects:[PFObject]?
    
    func getNextInstructor(){
        
        if currentInstructor < totalInstructors{
            var instructorObject = instructorObjects![currentInstructor]
            Instructor(object: instructorObject, delegate: self)
        } else {
            getNextUniversity()
        }
    }
    
    func instructorDownloadComplete(instructor: Instructor){
        instructors.append(instructor)
        currentInstructor++
        getNextInstructor()
    }
    
    
    // Handle University Initialization
    var totalUniversities = 0
    var currentUniversity = 0
    var universityObjects:[PFObject]?
    
    func getNextUniversity(){
        
        if currentUniversity < totalUniversities{
            var universityObject = universityObjects![currentUniversity]
            University(object: universityObject, delegate: self)
        } else {
            NSNotificationCenter.defaultCenter()
                .postNotificationName(kCourseCompleteNotificationName, object: self)
            
        }
    }
    
    func universityDownloadComplete(university: University){
        universities.append(university)
        currentUniversity++
        getNextUniversity()
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

        if object.isIncluded() {
            
            self.delegate = delegate
            
            NSNotificationCenter.defaultCenter()
                .addObserver(self, selector: "photoDownloaded:",
                    name: "PhotoSet", object: nil)
            NSNotificationCenter.defaultCenter()
                .addObserver(self, selector: "largeIconDownloaded:",
                    name: "LargeIconSet", object: nil)
            NSNotificationCenter.defaultCenter()
                .addObserver(self, selector: "smallIconDownloaded:",
                    name: "SmallIconSet", object: nil)

            getPhoto(object)
        }
        
    }
    
    func photoDownloaded(notification: NSNotification){
        
        NSNotificationCenter.defaultCenter()
            .removeObserver(self, name: "PhotoSet", object: nil)
        getLargeIcon(notification.object as! PFObject)
    }
    
    func largeIconDownloaded(notification: NSNotification){
        
        NSNotificationCenter.defaultCenter()
            .removeObserver(self, name: "LargeIconSet", object: nil)
        getSmallIcon(notification.object as! PFObject)
        
    }
    
    func smallIconDownloaded(notification: NSNotification){
        NSNotificationCenter.defaultCenter()
            .removeObserver(self, name: "SmallIconSet", object: nil)
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
                        println("Photo data is nil")
                    }
                } else {
                    println("Error downloading photo PFFile")
                }
                NSNotificationCenter.defaultCenter()
                    .postNotificationName("PhotoSet", object: object)
            }
        } else {
            println("Warning: photoImageFile is nil")
            NSNotificationCenter.defaultCenter()
                .postNotificationName("PhotoSet", object: object)
        }
    }
    
    func getLargeIcon(object: PFObject){
        
        if let largeIconImageFile = object["largeIcon"] as? PFFile {
            
            largeIconImageFile.getDataInBackgroundWithBlock{
                (data:NSData?, error:NSError?) in
                
                if error == nil{
                    
                    if let data = data {
                        self.largeIconData = data
                    } else {
                        println("Large Icon data is nil")
                    }
                } else {
                    println("Error downloading large icon PFFile")
                }
                NSNotificationCenter.defaultCenter()
                    .postNotificationName("LargeIconSet", object: object)
            }
        } else {
            println("Warning: largeIconImageFile is nil")
            NSNotificationCenter.defaultCenter()
                .postNotificationName("LargeIconSet", object: object)
        }
    }
    
    func getSmallIcon(object: PFObject){
        
        if let smallIconImageFile = object["smallIcon"] as? PFFile {
            smallIconImageFile.getDataInBackgroundWithBlock{
                (data:NSData?, error:NSError?) in
                
                if error == nil {
                    
                    if let data = data {
                        self.smallIconData = data
                    } else {
                        println("Small Icon data is nil")
                    }
                } else {
                    println("Error downloading small icon PFFile")
                }
                NSNotificationCenter.defaultCenter()
                    .postNotificationName("SmallIconSet", object: object)
            }
        } else {
            println("Warning: small icon image file is nil")
            NSNotificationCenter.defaultCenter()
                .postNotificationName("SmallIconSet", object: object)
            
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
        
        if object.isIncluded() {
            
        }
        
        super.init(object: object)

    }
}

//MARK:- Instructor
protocol InstructorSetDelegateProtocol {
    func instructorDownloadComplete(instructor: Instructor)
}

class Instructor : Base, ImageSetDelegateProtocol
{
    var image = Image()
    var courses = [Course]()
    var website = String()
    var delegate: InstructorSetDelegateProtocol?
    
    override init() {
        super.init()
    }
    
    override init(object: PFObject){
        super.init(object: object)
        
    }
    
    convenience init(object: PFObject, delegate: InstructorSetDelegateProtocol) {
        
        self.init(object: object)
        
        if object.isIncluded() {
            self.delegate = delegate
            
            if let website = object["website"] as? String {
                self.website = website
            }
            
            if let imageObject = object["image"] as? PFObject {
                
                if imageObject.isIncluded() {
                    Image(object: imageObject, delegate: self)

                } else {
                    executeProtocol()
                }
            }
        }
    }
    
    func imageDownloadComplete(image: Image) {
        self.image = image
        executeProtocol()
    }
    
    func executeProtocol(){
        if let delegate = delegate {
            delegate.instructorDownloadComplete(self)
        } else {
            assert(false,"Instructor delegate not yet set")
        }
    }
}

//MARK: - University
protocol UniversitySetDelegateProtocol {
    func universityDownloadComplete(university: University)
}

class University : Base, ImageSetDelegateProtocol
{
    var website = String()
    var image = Image()
    var courses = [Course]()
    var delegate: UniversitySetDelegateProtocol?
    
    override init() {
        super.init()
    }
    
    override init(object:PFObject) {
        super.init(object: object)
    }
    
    convenience init(object: PFObject, delegate: UniversitySetDelegateProtocol) {

        self.init(object: object)

        if object.isIncluded() {
            self.delegate = delegate
            
            if let website = object["website"] as? String {
                self.website = website
            }
            
            if let imageObject = object["image"] as? PFObject {
                
                if imageObject.isIncluded() {
                    Image(object: imageObject, delegate: self)
                } else {
                    executeProtocol()
                }
            }
        }
    }
    
    func imageDownloadComplete(image: Image) {
        self.image = image
        executeProtocol()
    }

    func executeProtocol(){
        if let delegate = delegate {
            delegate.universityDownloadComplete(self)
        } else {
            assert(false,"University delegate not yet set")
        }
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
        
        if object.isIncluded() {
            
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
        
        if object.isIncluded() {
            
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
    func isIncluded() -> Bool {
        return createdAt != nil
    }
    
}









