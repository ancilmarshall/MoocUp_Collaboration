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
        ("name","name"),
        ("shortDescription","summary"),
        ("photo","Image.photo"),
        ("smallIcon","Image.smallIcon"),
        ("largeIcon","Image.largeIcon"),
        ("language","language"),
        ("estimatedClassWorkload","workload"),
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
        ("id","id"),
        ("name","name"),
        ("description","summary"),

    ]
    
    //(apiKey,modelKey)
    let universityFields = [
        ("id","id"),
        ("name","name"),
        ("description","summary"),
        ("website","website"),
        ("banner","Image.photo"),
        ("classLogo","Image.largeIcon")
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
    
    //MARK:- MOOC API Manager public interface methods
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
    
    
    //MARK:- Data Models Creation Methods
    func getJSONData(endpoint: String, fields:[(String,String)], ids:[Int]?) -> [Dictionary<String,AnyObject>]{
        
        var jsonDataArray = [Dictionary<String,AnyObject>]()
        var url = NSURL()
        var queryItems = [NSURLQueryItem]()
        
        if endpoint == "courses" {
            let includesString = "instructors,categories,sessions,universities"
            if let inputArray = ids {
                var idsAssociatedData = ",".join(inputArray.map{"\($0)"})
                queryItems = getQueryItems(fromQueryNames:
                    [("fields" , apiQueryNames.fields(courseFields)),
                        ("ids" , apiQueryNames.ids(idsAssociatedData)),
                        ("includes", apiQueryNames.includes(includesString))]
                )
                url = getNSURL(fromEnpoint: endpoint, andQueryItems: queryItems)
            } else {
                queryItems = getQueryItems(fromQueryNames:
                    [("fields" , apiQueryNames.fields(courseFields)),
                        ("includes", apiQueryNames.includes(includesString))]
                )
                url = getNSURL(fromEnpoint: endpoint, andQueryItems: queryItems)
            }
        }
        else {
            if let inputArray = ids {
                var idsAssciatedData = ",".join(inputArray.map{"\($0)"})
                queryItems = getQueryItems(fromQueryNames:
                    [("fields", apiQueryNames.fields(fields)),
                        ("ids", apiQueryNames.ids(idsAssciatedData))]
                )
            }
        }
        
        url = getNSURL(fromEnpoint: endpoint, andQueryItems: queryItems)
        
        if let data = NSData(contentsOfURL: url) {
            jsonDataArray = parseJSONData(data)
        } else {
            assert(false,"Error retrieving data from url \(url)")
        }
        return jsonDataArray
    }
   
    func createSession(sessionJSONData: Dictionary<String,AnyObject>) -> Session {
        
        var session = Session()
        
        for (apiKey,modelKey) in sessionFields {
            
            var dateSet = false
            var day = Int()
            var month = Int()
            var year = Int()
            
            switch apiKey {
                
            case "id":
                if let value = sessionJSONData[apiKey] as? Int {
                    session.setValue(value, forKey:modelKey)
                } else {
                    println("Key \(apiKey) missing")
                }
                
            case "name","durationString","homeLink":
                if let value = sessionJSONData[apiKey] as? String{
                    session.setValue(value, forKey:modelKey)
                } else {
                    println("Key \(apiKey) missing")
                }
                
            case "startDay","startMonth","startYear":
                if (!dateSet) {
                    var dateComponents = NSDateComponents()
                    if let value = sessionJSONData["startDay"] as? Int {
                        dateComponents.day = value
                    }
                    if let value = sessionJSONData["startMonth"] as? Int {
                        dateComponents.month = value
                    }
                    if let value = sessionJSONData["startYear"] as? Int {
                        dateComponents.year = value
                    }
                    
                    if let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian){
                        if let date = calendar.dateFromComponents(dateComponents){
                            session.startDate = date
                        }
                    }
                    dateSet = true
                }
                
            default:
                println("Should not be here")
            }
        }
        return session
    }
    
    
    func createUniversity(universityJSONData: Dictionary<String,AnyObject>) -> University {
        
        var university = University()
        
        for (apiKey,modelKey) in universityFields {
            var imageSet = false
            switch apiKey {
                
            case "id":
                if let value = universityJSONData[apiKey] as? Int {
                    university.setValue(value, forKey:modelKey)
                } else {
                    println("Key \(apiKey) missing")
                }
                
            case "name","description","website":
                if let value = universityJSONData[apiKey] as? String{
                    university.setValue(value, forKey:modelKey)
                } else {
                    println("Key \(apiKey) missing")
                }
            
            case "banner","classLogo":
                if (!imageSet) {
                    var image = Image()
                    
                    image.photoData = imageData(fromDictionary:universityJSONData, forKey: "banner")
                    image.smallIconData = imageData(fromDictionary:universityJSONData, forKey: "classLogo")
                    
                    university.image = image
                    imageSet = true
                }
                
            default:
                println("Should not be here")
            }
        }
        return university
    }
    
    
    func createCategory(categoryJSONData: Dictionary<String,AnyObject>) -> Category {
        
        var category = Category()
        
        for (apiKey,modelKey) in categoryFields {
            
            switch apiKey {
                
            case "id":
                if let value = categoryJSONData[apiKey] as? Int {
                    category.setValue(value, forKey:modelKey)
                } else {
                    println("Key \(apiKey) missing")
                }
                
            case "name","description":
                if let value = categoryJSONData[apiKey] as? String{
                    category.setValue(value, forKey:modelKey)
                } else {
                    println("Key \(apiKey) missing")
                }
                
            default:
                println("Should not be here")
            }
        }
        return category
    }
    
    func createInstructor(instructorJSONData: Dictionary<String,AnyObject>) -> Instructor {
        
        var instructor = Instructor()
    
        var imageSet = false
        var firstNameSet = false
        var lastNameSet = false
        var firstName = String()
        var lastName = String()
        
        for (apiKey,modelKey) in instructorFields {
            
            switch apiKey {
            
            case "id":
                if let value = instructorJSONData[apiKey] as? Int {
                    instructor.setValue(value, forKey:modelKey)
                } else {
                    println("Key \(apiKey) missing from Instructor")
                }
                
            case "bio","website":
                if let value = instructorJSONData[apiKey] as? String{
                    instructor.setValue(value, forKey:modelKey)
                } else {
                    println("Key \(apiKey) missing from Instructor")
                }
            
            case "firstName":
                firstNameSet = true
                if let value = instructorJSONData[apiKey] as? String {
                    firstName = value
                }
                
                if firstNameSet && lastNameSet {
                    instructor.name = firstName + " " + lastName
                }
                
            case "lastName":
                lastNameSet = true
                if let value = instructorJSONData[apiKey] as? String {
                    lastName = value
                }
                
                if firstNameSet && lastNameSet {
                    instructor.name = firstName + " " + lastName
                }
                
            case "photo","photo150":
                if (!imageSet) {
                    var image = Image()
                    
                    image.photoData = imageData(fromDictionary:instructorJSONData, forKey: "photo")
                    image.smallIconData = imageData(fromDictionary:instructorJSONData, forKey: "photo150")
                    
                    instructor.image = image
                    imageSet = true
            }
                
            default:
                println("Should not be here")
            }
        }
        return instructor
    }
    
    func createCourse(courseJSONData: Dictionary<String,AnyObject>) ->
        (Course,
         [Dictionary<String,AnyObject>],
         [Dictionary<String,AnyObject>],
         [Dictionary<String,AnyObject>],
         [Dictionary<String,AnyObject>])
    {
        var course = Course()
        
        for (apiKey,modelKey) in courseFields {
            var imageSet = false
            
            switch apiKey {
                
            case "id":
                if let value = courseJSONData[apiKey] as? Int {
                    course.setValue(value, forKey:modelKey)
                } else {
                    println("Key \(apiKey) missing from Course")
                }
                
            case "name",
            "shortDescription",
            "estimatedClassWorkload",
            "video",
            "recommendedBackground",
            "targetAudiance":
                
                if let value = courseJSONData[apiKey] as? String{
                    course.setValue(value, forKey:modelKey)
                } else {
                    println("Key \(apiKey) missing from Course with Id: \(course.id)")
                }
                
            case "language":
                //TODO Check many-many relation
                //TODO transform from en to English
                
                var newLanguage = Language()
                
                if let value = courseJSONData[apiKey] as? String{
                    newLanguage.language = value
                } else {
                    println("Key \(apiKey) missing from Course with Id: \(course.id)")
                }
                
                course.languages.append(newLanguage)
                languages.append(newLanguage)
                
            case "photo","largeIcon","smallIcon":
                
                if (!imageSet) {
                    
                    var image = Image()
                    image.photoData = imageData(fromDictionary:courseJSONData, forKey: "photo")
                    image.smallIconData = imageData(fromDictionary:courseJSONData, forKey: "largeIcon")
                    image.largeIconData = imageData(fromDictionary:courseJSONData, forKey: "smallIcon")
                    
                    //Each image is a one to one relationship with no need to track image objects in a list of images
                    course.image = image
                    imageSet = true
                }
            default:
                var dummy = false
            }
        }
        
        var links = courseJSONData["links"] as! Dictionary<String,[Int]>
        var instructorJSONData = [Dictionary<String,AnyObject>]()
        var sessionJSONData = [Dictionary<String,AnyObject>]()
        var universityJSONData = [Dictionary<String,AnyObject>]()
        var categoryJSONData = [Dictionary<String,AnyObject>]()

        if let ids = links["instructors"] {
            instructorJSONData = getJSONData("instructors",fields: instructorFields,ids: ids)
        }
        
        if let ids = links["sessions"] {
            sessionJSONData = getJSONData("sessions",fields:sessionFields,ids:ids)
        }
        
        if let ids = links["universities"]{
            universityJSONData = getJSONData("universities", fields:universityFields, ids: ids)
        }
        
        if let ids = links["categories"]{
            categoryJSONData = getJSONData("categories", fields:categoryFields, ids: ids)
        }
        
        return (course, instructorJSONData, sessionJSONData, universityJSONData, categoryJSONData)
    }
    
    // Root function call. Create a Course and all the relative objects connected to it
    func fetchCoursesFromApi() -> [Course]
    {
        //create a Coursera Mooc instance
        var mooc = Mooc()
        mooc.name = "Coursera"
        
        var coursesJSONData = getJSONData("courses",fields:courseFields, ids: [69,2163,1322,2822,1411])
        
        //loop through all fetchedCourses and construct Course model
        for courseData in coursesJSONData
        {
            ///// For each Course, here are the steps /////
            var results = createCourse(courseData)
            var course = results.0
            var instructorJSONData = results.1
            var sessionJSONData = results.2
            var universityJSONData = results.3
            var categoryJSONData = results.4
            
            if !contains(courses, course)
            {
                courses.append(course)
                
                //TODO: This if not nil first
                for instructorData in instructorJSONData {
                    
                    //get instructor with basic information filled out
                    var instructor = createInstructor(instructorData)
                    
                    //check if this instructor is not already in list of instructors
                    if !contains(instructors,instructor){
                        //so this is a brand new instructor, append it to the global list
                        instructors.append(instructor)
                        
                    } else
                    // get the instructor pointer from the list of instructors (replacing the newInstructor)
                    {
                        //TODO: Check that this actually works for a many-many relationship
                        var index = (instructors as NSArray).indexOfObject(instructor)
                        instructor = (instructors as NSArray).objectAtIndex(index) as! Instructor
                        
                    }
                    
                    // then add the connection between instructor and course
                    course.instructors.append(instructor)
                    instructor.courses.append(course)
                }
                
                for categoryData in categoryJSONData {
                    
                    //FIXME: This is performing redundant network calls
                    var category = createCategory(categoryData)
                    
                    if !contains(categories,category){
                        categories.append(category)
                    } else {
                        var index = (categories as NSArray).indexOfObject(category)
                        category = (categories as NSArray).objectAtIndex(index) as! Category
                    }
                    
                    course.categories.append(category)
                    category.courses.append(course)
                    
                }
                
                for sessionData in sessionJSONData {
                    
                    //FIXME: This is performing redundant network calls
                    var session = createSession(sessionData)
                    
                    if !contains(sessions,session){
                        sessions.append(session)
                    } else {
                        var index = (sessions as NSArray).indexOfObject(session)
                        session = (sessions as NSArray).objectAtIndex(index) as! Session
                    }
                    
                    course.sessions.append(session)
                    session.course = course
                    
                }
                
                for universityData in universityJSONData {
                    
                    //FIXME: This is performing redundant network calls
                    var university = createUniversity(universityData)
                
                    if !contains(universities,university){
                        universities.append(university)
                    } else {
                        var index = (universities as NSArray).indexOfObject(university)
                        university = (universities as NSArray).objectAtIndex(index) as! University
                    }
                    
                    course.universities.append(university)
                    university.courses.append(course)
                    
                }
                
            }
            else {
                //get course pointer from list. Should not happen since courses are out root object created. Only created once
            }
            
            //TODO: make this a many to many relationship for future
            //For now, keep it 1-many 
            course.moocs.append(mooc)
            mooc.courses.append(course)
            
        }
        println("Network Requests: \(networkRequests)")
        return courses
    }
    
    //MARK: - Helper functions
    // guarantee that this function returns and unwrapped Optional
    func parseJSONData(data: NSData) -> [Dictionary<String,AnyObject>] {
        
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
    
    func imageData(fromDictionary dict: Dictionary<String,AnyObject>,
        forKey key: String) -> NSData {
            
            if let URLString = dict[key] as? String {
                if let URL =  NSURL(string: URLString) {
                    if let data = NSData(contentsOfURL: URL){
                        return data
                    } else {
                        println("Error create NSData: \(URL)")
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
    
    var networkRequests = 0
    func getNSURL(fromEnpoint endpoint: String, andQueryItems items:[NSURLQueryItem])->NSURL
    {
        networkRequests++
        
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