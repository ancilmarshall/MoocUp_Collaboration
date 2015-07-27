//
//  CourseraApiManager.swift
//  MoocApiParseApp
//
//  Created by Ancil on 7/24/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import Foundation
import Parse


class CourseraApiManager
{
    
    let MUServerScheme = "https"
    let MUServerHost = "api.coursera.org"
    let MUServerPath = "/api/catalog.v1/"
    let kCourseClassName = "Course"
    let kMoocName = "Coursera"
    
    //(apiKey, modelKey)
    let courseFields = [
        ("id","id"), //Int
        ("name","name"), //String
        ("shortDescription","summary"), // String
        ("photo","Image.photo"), //String
        ("smallIcon","Image.smallIcon"), //String
        ("largeIcon","Image.largeIcon"), //String
        ("language","language"), //String
        ("estimatedClassWorkload","workload"), //String
        ("targetAudience","targetAudience"),
        ("video","videoLink"),
        ("recommendedBackground","prerequisite")
    ]
    
    //(apiKey,modelKey)
    let sessionFields = [
        ("id","id"),
        ("name","name"),
        ("durationString","duration"),
        ("homeLink","homeLink"),
        ("startDay","startDate"),
        ("startMonth","startDate"),
        ("startYear","startDate")
    ]
    
    //(apiKey,modelKey)
    let instructorFields = [
        ("id","id"),
        ("firstName","name"),
        ("lastName","name"),
        ("bio","summary"),
        ("photo","Image.photo"),
        ("photo150","Image.largeIcon"),
        ("website","website")
    ]
    
    //(apiKey,modelKey)
    let categoryFields = [
    
    ]
    
    
    enum apiQueryNames {
        case fields(Array<(String,String)>)
        case includes(String)
        case ids(String)
    }
    
    var courses = [Course]()
    var universities = [University]()
    var sessions = [Session]()
    var categories = [Category]()
    var languages = [Language]()
    var moocs = [Mooc]()
    var users = [User]()
    var instructors = [Instructor]()
    
    // guarantee that this function returns and unwrapped Optional
    func parseJSONData(data: NSData) -> [Dictionary<String,AnyObject>]{
        
        //get data as a dictionary
        if let jsonDict = NSJSONSerialization.JSONObjectWithData(
            data, options: nil, error: nil) as? Dictionary<String,AnyObject>
        {
            //value of the outer dictionary's element key contains the data desired
            if let jsonData = jsonDict["elements"] as? [Dictionary<String,AnyObject>] {
                return jsonData
            } else {
                assert(false,"Expected returned JSON 'elements' key to be non-nil")
            }
        } else {
            assert(false,"Expected returned JSON data to be non-nil")
        }
    }
    
    func fetchCoursesFromApiWithBlock(block handler: ([Course])->Void ){
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
        
        var backgroundqueue = NSOperationQueue()
        var operation = NSBlockOperation { () -> Void in
            var courses = self.fetchCoursesFromApi()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
            handler(courses)
        }
        backgroundqueue.addOperation(operation)
    
    }
    
    func fetchInstructorFromApiWithId(id: Int) -> Instructor {
        
        let endpoint = "instructors"
        let queryItems = getQueryItems(fromQueryNames:
            [("fields", apiQueryNames.fields(instructorFields)),
             ("ids", apiQueryNames.ids("\(id)"))]
        )
    
        let url = getNSURL(fromEnpoint: endpoint, andQueryItems: queryItems)
        var fetchedApiObjects = [Dictionary<String,AnyObject>]()
        if let data = NSData(contentsOfURL: url) {
            fetchedApiObjects = parseJSONData(data)
        } else {
            assert(false,"Error retrieving data from url \(url)")
        }
        
        var newInstructor = Instructor()
        if let fetchedObject = fetchedApiObjects.first {
            
            var imageSet = false
            var firstNameSet = false
            var lastNameSet = false
            var firstName = String()
            var lastName = String()
            
            for (apiKey,modelKey) in instructorFields {
                
                switch apiKey {
                
                case "id":
                    if let value = fetchedObject[apiKey] as? Int {
                        newInstructor.setValue(value, forKey:modelKey)
                    } else {
                        println("Key \(apiKey) missing from Instructor")
                    }
                    
                case "bio","website":
                    if let value = fetchedObject[apiKey] as? String{
                        newInstructor.setValue(value, forKey:modelKey)
                    } else {
                        println("Key \(apiKey) missing from Instructor")
                    }
                
                case "firstName":
                    firstNameSet = true
                    if let value = fetchedObject[apiKey] as? String {
                        firstName = value
                    }
                    
                    if firstNameSet && lastNameSet {
                        newInstructor.name = firstName + " " + lastName
                    }
                    
                case "lastName":
                    lastNameSet = true
                    if let value = fetchedObject[apiKey] as? String {
                        lastName = value
                    }
                    
                    if firstNameSet && lastNameSet {
                        newInstructor.name = firstName + " " + lastName
                    }
                    
                case "photo","photo150":
                    if (!imageSet) {
                        var image = Image()
                        
                        image.photoData = imageData(fromDictionary:fetchedObject, forKey: "photo")
                        image.smallIconData = imageData(fromDictionary:fetchedObject, forKey: "photo150")
                        
                        newInstructor.image = image
                        imageSet = true
                }
                    
                default:
                    println("Should not be here")
                }
            }
        }
        return newInstructor
    }

    
    func fetchCoursesFromApi() -> [Course]
    {
        
        //create a Coursera Mooc instance
        var mooc = Mooc()
        mooc.name = "Coursera"
        
        // setup url and get json data
        let endpoint = "courses"
        let queryItems = getQueryItems(fromQueryNames:
            [("fields" , apiQueryNames.fields(courseFields)),
            ("ids" , apiQueryNames.ids("2163,69,1322,2822,1411")),
            ("includes", apiQueryNames.includes("instructors"))]
        )
        let url = getNSURL(fromEnpoint: endpoint, andQueryItems: queryItems)
        
        var fetchedApiObjects = [Dictionary<String,AnyObject>]()
        if let data = NSData(contentsOfURL: url) {
            fetchedApiObjects = parseJSONData(data)
        } else {
            assert(false,"Error retrieving data from url \(url)")
        }
        
        //loop through all fetchedCourses and construct Course model
        for course in fetchedApiObjects
        {
            var imageSet = false
            
            var newCourse = Course()
            newCourse.id = course["id"] as! Int
            
            if !contains(courses, newCourse)
            {
                courses.append(newCourse)
                
                //TODO: make this a many to many relationship
                newCourse.moocs.append(mooc)
                
                for (apiKey,modelKey) in courseFields {
                    
                    switch apiKey {
                        
                    case "name",
                        "shortDescription",
                        "estimatedClassWorkload",
                        "video",
                        "recommendedBackground",
                        "targetAudiance":
                        
                        if let value = course[apiKey] as? String{
                            newCourse.setValue(value, forKey:modelKey)
                        } else {
                            println("Key \(apiKey) missing from Course with Id: \(newCourse.id)")
                        }
                    
                    case "language":
                        //TODO Check many-many relation
                        //TODO transform from en to English
                        
                        var newLanguage = Language()
                        
                        if let value = course[apiKey] as? String{
                            newLanguage.language = value
                        } else {
                            println("Key \(apiKey) missing from Course with Id: \(newCourse.id)")
                        }
                        
                        newCourse.languages.append(newLanguage)
                        languages.append(newLanguage)
                        
                    case "photo","largeIcon","smallIcon":
                        
                        if (!imageSet) {
                            
                            var image = Image()
                            image.photoData = imageData(fromDictionary:course, forKey: "photo")
                            image.smallIconData = imageData(fromDictionary:course, forKey: "largeIcon")
                            image.largeIconData = imageData(fromDictionary:course, forKey: "smallIcon")
                            
                            //Each image is a one to one relationship with no need to track image objects in a list of images
                            newCourse.image = image
                            imageSet = true
                        }
                    default:
                        var dummy = false
                    }
                }
                
                var links = course["links"] as! Dictionary<String,[Int]>
                
                var instructorIds = links["instructors"]
                var sessionIds = links["sessions"]
                var universityIds = links["universities"]
                var categoryIds = links["categories"]
                
                
                if let ids = instructorIds {
                
                    for instructorId in ids {
                        
                        //get instructor with basic information filled out
                        var newInstructor = fetchInstructorFromApiWithId(instructorId)
                        
                        //check if this instructor is not already in list of instructors
                        if !contains(instructors,newInstructor){
                            //so this is a brand new instructor, append it to the global list
                            instructors.append(newInstructor)
                            
                        } else
                        // get the instructor pointer from the list of instructors (replacing the newInstructor)
                        {
                            //TODO: Check that this actually works for a many-many relationship
                            var index = (instructors as NSArray).indexOfObject(newInstructor)
                            newInstructor = (instructors as NSArray).objectAtIndex(index) as! Instructor
                            
                        }
                        
                        // then add the connection between instructor and course
                        newCourse.instructors.append(newInstructor)
                        newInstructor.courses.append(newCourse)
                    }
                }
                
                
            }
        }
        return courses
    }
    
//    func fetchInstructorsFromApi() -> [Instructor]
//    {
//        let endpoint = "instructors"
//        let queryItems = getQueryItems(fromQueryNames: ["i_fields","i_includes"])
//        let url = getNSURL(fromEnpoint: endpoint, andQueryItems: queryItems)
//        let data = NSData(contentsOfURL: url)!
//        
//        return [Instructor]()
//    }
    
    
    func imageData(fromDictionary dict: Dictionary<String,AnyObject>,
        forKey key: String) -> NSData {
            
            if let URLString = dict[key] as? String {
                if let URL =  NSURL(string: URLString) {
                    if let data = NSData(contentsOfURL: URL){
                        return data
                    } else {
                        println("Error create NSData")
                    }
                } else {
                    println("Error creating URL")
                }
            } else {
                println("Key \(key) missing from Object: \(dict)")
            }
            return NSData()
    }
    
    
    //FIXME: Convert to strings the attributes in Course model that are not other models
    func saveCoursesToParse(courses: [Course]) -> Void
    {
        for course in courses {
            var entity = PFObject(className: kCourseClassName )
            
            //can only set String values when iterating over this for loop
            for (apiKey,modelKey) in courseFields {
                //TODO: Change all these Course values to Strings
                var entityValue = course.valueForKey(apiKey) as! String
                entity.setValue(entityValue, forKey: modelKey)
            }
            
            //set fixed values and relationships to other models manually here
            entity["mooc"] = kMoocName
            //entity.saveInBackground()
        }
    }
    
    //MARK: -  URL Contruction
    func getQueryItems(fromQueryNames names:[(String,apiQueryNames)])->[NSURLQueryItem]
    {
        var queryItems = [NSURLQueryItem]()
        for (name, queries) in names {
            if let value = getQueryValue(forName: queries) {
                queryItems.append(NSURLQueryItem(name: name, value: value))
            } else {
                assert(false,"Error in getQueryItems(fromQueryNames)")
            }
        }
        return queryItems
    }
    
    func getQueryValue(forName name:apiQueryNames) -> String? {
        
        switch name {
            
        case .fields(let fields):
            return ",".join(fields.map({ (apiKey, modelKey) -> String in
                return apiKey
            }))
            
        case .ids(let str):
            return str
        
        case .includes(let str):
            return str
            
        default:
            return nil
        }
    }
    
    func getNSURL(fromEnpoint endpoint: String, andQueryItems items:[NSURLQueryItem])->NSURL
    {
        var components:NSURLComponents = NSURLComponents()
        components.scheme = MUServerScheme
        components.host = MUServerHost
        components.path = MUServerPath + endpoint
        components.queryItems = items
        
        if let url = components.URL{
            return url
        } else {
            assert(false,"Error in getNSURL(fromEndpoint,andQueryItems)")
        }
    }
    

   
    
    
}