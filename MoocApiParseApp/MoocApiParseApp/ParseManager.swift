//
//  MUParseManager.swift
//  MoocApiParseApp
//
//  Created by Ancil on 7/24/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import Foundation
import Parse

class ParseManager
{
    func fetchCourses(query:PFQuery, completionHandler:(courses:[Course])->Void )
    {
        var courses = [Course]()
                
        query.findObjectsInBackgroundWithBlock {
            ( objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                if let foundCourses = objects as? [PFObject] {
                
                    for course in foundCourses  {
                        var newCourse = Course()
                        newCourse.name = course["name"] as! String
                        
    //                    var newImage = Image()
    //                    if let imageObject = course["image"] as? PFObject{
    //                        let photoImageFile = imageObject["photo"] as! PFFile
    //                            if let photoData = photoImageFile.getData(){
    //                                newImage.photoData = photoData
    //                        }
    //                    }
                        
                        courses.append(newCourse)
                    }
                }
            }
            else {
                println("Error fetching parse data")
            }
            completionHandler(courses: courses)
        }
        
    }
    
}