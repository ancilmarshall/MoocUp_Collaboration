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
    let kMUMoocName = "Coursera"
    
    //parseKey, apiKey
    let courseFields = [
        ("id","id"), //String
        ("name","name"), //String
        ("shortName","shortName"), //String
        ("photo","photo"), //String
        ("thumbnail","smallIcon"), //String
        ("language","language"), //String
        ("workload","estimatedClassWorkload") //String
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
    var sessions = [Session]()
    
    
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
        //setup url and get json data
        let endpoint = "courses"
        let queryItems = getQueryItems(fromQueryNames: ["fields","includes"])
        let url = getNSURL(fromEnpoint: endpoint, andQueryItems: queryItems)
        let data = NSData(contentsOfURL: url)!
        
        var coursesFetched = parseJSONData(data)
    
        //loop through all fetchedCourses and construct Course model
        var newCourses = [Course]()
        for course in coursesFetched {
            var newCourse = Course()
            for (parseKey,apiKey) in courseFields {
                newCourse.setValue(course[apiKey], forKey: parseKey)
            }
            
            //set fixed mooc name for this manager
            newCourse.setValue(kMUMoocName, forKey:"mooc")
            
            // get the relationship information if available
            // NOTE: these [Int]? and therefore can be nil
            var links = course["links"] as! Dictionary<String,[Int]>
            newCourse.instructorIds = links["instructors"]
            newCourse.sessionIds = links["sessions"]
            newCourse.universityIds = links["universities"]
            newCourse.categoryIds = links["categories"]
            
            newCourses.append(newCourse)
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
            for (parseKey,apiKey) in courseFields {
                //TODO: Change all these Course values to Strings
                var entityValue = course.valueForKey(apiKey) as! String
                entity.setValue(entityValue, forKey: parseKey)
            }
            
            //set fixed values and relationships to other models manually here
            entity["mooc"] = kMUMoocName
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
            return ",".join(courseFields.map({ (parseKey, apiKey) -> String in
                return apiKey
            }))
        
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