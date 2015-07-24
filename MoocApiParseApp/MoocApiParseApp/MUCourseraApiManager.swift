//
//  MUCourseraApiManager.swift
//  MoocApiParseApp
//
//  Created by Ancil on 7/24/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import Foundation
import Parse

let MUServerScheme = "https"
let MUServerHost = "api.coursera.org"
let MUServerPath = "/api/catalog.v1/"


class MUCourseraApiManager
{
    
    //MARK: - data members
    let courseFields = [
        "id",
        "shortName",
        "name",
        "language",
        "photo",
        "smallIcon"
    ]
    
    func fetchCoursesFromApi() -> [Dictionary<String,AnyObject>]
    {
        let endpoint = "courses"
        var courses = [Dictionary<String,AnyObject>]()
        let queryItems = getQueryItems(fromQueryNames: ["fields"])
        let url = getNSURL(fromEnpoint: endpoint, andQueryItems: queryItems)
        let data = NSData(contentsOfURL: url)!
        
        var coursesDict = NSJSONSerialization.JSONObjectWithData(
            data, options: nil, error: nil)!
            as! Dictionary<String,AnyObject>
        
        courses = coursesDict["elements"]! as! [Dictionary<String,AnyObject>]
        return courses
    }
    
    func saveCoursesToParse(courses: [Dictionary<String,AnyObject>]) -> Void
    {
        
        for course in courses {
            var entity = PFObject(className: "MUCourse")
            entity["name"] = course["name"] as! String
            entity["photo"] = course["photo"] as! String
            entity["mooc"] = "Coursera"
            
            entity.saveInBackground()
        }
    }
    
    
    //MARK: - URL Construction Methods
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
    
    func getQueryValue(forName name:String) -> String? {
        
        switch name {
        case "fields":
            return ",".join(courseFields)
            
        default:
            return nil
        }
    }
   
    
    
}