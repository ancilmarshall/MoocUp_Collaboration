//
//  MUParseManager.swift
//  MoocApiParseApp
//
//  Created by Ancil on 7/24/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import Foundation
import Parse

class MUParseManager
{
    
    func fetchCourses(query:PFQuery, completionHandler:(courses:[MUCourse])->Void )
    {
        var courses = [MUCourse]()
                
        query.findObjectsInBackgroundWithBlock {
            ( foundCourses: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                for course in foundCourses as! [PFObject] {
                    var newCourse = MUCourse()
                    newCourse.name = course["name"] as! String
                    newCourse.photo = course["photo"] as! String
                    newCourse.mooc = course["mooc"] as! String
                    
                    courses.append(newCourse)
                }
            }
            else {
                println("Error fetching parse data")
            }
            completionHandler(courses: courses)
        }
        
    }
    
}