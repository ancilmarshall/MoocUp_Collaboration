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
    
    let sessionFields = [
        ("id","id"),
        ("name","name"),
        ("duration","durationString")
    ]
    
    let instructorFields = [
        ("id","id"),
        ("name","name")
    ]
    
    var courses = [Course]()
    var universities = [University]()
    var sessions = [Session]()
    var categories = [Category]()
    var languages = [Language]()
    var moocs = [Mooc]()
    var users = [User]()
    
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
    
    func fetchCoursesFromApi() -> [Course]
    {
        
        var imageSet = false
        var mooc = Mooc()
        mooc.name = "Coursera"
        
        //setup url and get json data
        let endpoint = "courses"
        let queryItems = getQueryItems(fromQueryNames: ["fields","ids"])
        let url = getNSURL(fromEnpoint: endpoint, andQueryItems: queryItems)
        var coursesFetched = [Dictionary<String,AnyObject>]()
        if let data = NSData(contentsOfURL: url) {
            coursesFetched = parseJSONData(data)
        } else {
            assert(false,"Error retrieving data from url \(url)")
        }
        
        //loop through all fetchedCourses and construct Course model
        var newCourses = [Course]()
        for course in coursesFetched
        {
            var newCourse = Course()
            newCourse.id = course["id"] as! Int
            
            if !contains(courses, newCourse)
            {
                courses.append(newCourse)
                newCourses.append(newCourse)
                
                newCourse.moocs.append(mooc) //TODO: make this a many to many relationship
                
                for (apiKey,modelKey) in courseFields {
                    
                    switch apiKey {
                        
                    case "name",
                        "shortDescription",
                        "estimatedClassWorkload",
                        "video",
                        "recommendedBackground",
                        "targetAudiance":
                        
                        newCourse.setValue(course[apiKey], forKey:modelKey)
                    
                    case "language":
                        //TODO Check many-many relation
                        //TODO transform from en to English
                        
                        var newLanguage = Language()
                        newLanguage.language = course[apiKey] as! String
                        
                        
                        newCourse.languages.append(newLanguage)
                        languages.append(newLanguage)
                        
                    case "photo","largeIcon","smallIcon":
                    if (!imageSet) {
                        var image = Image()
                        image.photoURL =  NSURL(string: course["photo"] as! String)!
                        image.smallIconURL = NSURL(string: course["smallIcon"] as! String)!
                        image.largeIconURL = NSURL(string: course["largeIcon"] as! String)!
                        
                    
                        image.photoData = NSData(contentsOfURL: image.photoURL)!
                        image.smallIconData = NSData(contentsOfURL: image.smallIconURL)!
                        image.largeIconData = NSData(contentsOfURL: image.largeIconURL)!
                        
                        
                        //NOTE: Each image is a one to one relationship with it's parent
                        //      so no need to track image objects in a list of images
                        newCourse.image = image
                        imageSet = true
                    }
                    default:
                        var dummy = false
                    }
                }
                
                // get the relationship information if available
                // NOTE: these [Int]? and therefore can be nil
//                var links = course["links"] as! Dictionary<String,[Int]>
//                newCourse.instructorIds = links["instructors"]
//                newCourse.sessionIds = links["sessions"]
//                newCourse.universityIds = links["universities"]
//                newCourse.categoryIds = links["categories"]
            }
        }
        return newCourses
    }
    
    func fetchInstructorsFromApi() -> [Instructor]
    {
        let endpoint = "instructors"
        let queryItems = getQueryItems(fromQueryNames: ["i_fields","i_includes"])
        let url = getNSURL(fromEnpoint: endpoint, andQueryItems: queryItems)
        let data = NSData(contentsOfURL: url)!
        
        return [Instructor]()
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
    func getQueryItems(fromQueryNames names:[String])->[NSURLQueryItem]
    {
        var queryItems = [NSURLQueryItem]()
        for name in names {
            if let value = getQueryValue(forName: name) {
                queryItems.append(NSURLQueryItem(name: name, value: value))
            } else {
                assert(false,"Error in getQueryItems(fromQueryNames)")
            }
        }
        return queryItems
    }
    
    func getQueryValue(forName name:String) -> String? {
        
        switch name {
            
        case "fields":
            return ",".join(courseFields.map({ (apiKey, modelKey) -> String in
                return apiKey
            }))
            
        case "ids":
            return "2163,69,1322,2822,1411"
        
        case "includes":
            return "instructors,universities,categories,sessions"
            
//        case "i_fields":
//            return ",",join()
            
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