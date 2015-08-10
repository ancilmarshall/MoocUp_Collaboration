//
//  MUTableViewController.swift
//  MoocUp-ApiParseInterface
//
//  Created by Ancil on 7/22/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import UIKit
import Parse

let kTableViewCellIdentifier = "cell"
let kCourseClassName = "Course"

class CourseTableViewController: UITableViewController {


    //MARK: - data members
    
    let moocApiManager = CourseraApiManager()
    let parseManager = ParseManager()
    var courses:[Course] = [Course]()
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        //must correctly use autolayout in the storyboad for this to work
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        fetchFromMoocApi(nil)
        //fetchFromParse(nil)
    }
    
    
    @IBAction func fetchFromMoocApi(sender:AnyObject?)
    {
        moocApiManager.fetchCoursesFromApiWithBlock { newCourses in
            self.courses = newCourses
            dispatch_async(dispatch_get_main_queue()){
                self.tableView.reloadData()
                self.moocApiManager.saveCoursesToParse(newCourses)
            }
        }
    }

    let queryLimit :Int? = 5
    
    @IBAction func fetchFromParse(sender:AnyObject?)
    {
        var query = PFQuery(className: kCourseClassName)
        query.includeKey("image")
        query.includeKey("moocs")
        query.includeKey("instructors")
        query.includeKey("categories")
        query.includeKey("sessions")
        query.includeKey("universities")
        if let limit = queryLimit {
            query.limit = limit
        }
        
        query.findObjectsInBackgroundWithBlock {
            ( objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                if let foundCourses = objects as? [PFObject] {
                    
                    for course in foundCourses  {
                        
                        var newCourse = Course()
                        newCourse.id = course["id"] as! String
                        newCourse.name = course["name"] as! String
                        newCourse.summary = course["summary"] as! String
                        
                    
//                        self.addImage(course, { (image:Image?) in
//                            if let image = image {
//                                newCourse.image = image
//                                dispatch_async(dispatch_get_main_queue()){
//                                    self.tableView.reloadData()
//                                }
//                            }
//                        })
                        
                        if let instructors = course.objectForKey("instructors") as? [PFObject] {
                            newCourse.instructors = instructors.map{ Instructor(object: $0) }
                        }

                        if let universities = course["universities"] as? [PFObject] {
                            newCourse.universities = universities.map{ University(object: $0) }
                        }
                        
                        if let sessions = course["sessions"] as? [PFObject] {
                            newCourse.sessions = sessions.map{ Session(object: $0) }
                        }
                        
                        if let categories = course["categories"] as? [PFObject] {
                            newCourse.categories = categories.map{ Category(object: $0) }
                        }
                        
                        self.courses.append(newCourse)
                        
                        if let limit = self.queryLimit {
                            if self.courses.count == limit {
                                dispatch_async(dispatch_get_main_queue()){
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
            else {
                println("Error fetching parse data")
            }
        }
    }
    

    
    func addImage(course:PFObject, _ completionHandler:(image:Image?)->Void ){
        
        var newImage = Image()
        if let imageObject = course["image"] as? PFObject {
            let photoImageFile = imageObject["photo"] as! PFFile
            photoImageFile.getDataInBackgroundWithBlock{ (data:NSData?, error:NSError?) -> Void in
            
                if let data = data{
                    newImage.photoData = data
                }
            }
        }
        completionHandler(image: newImage)
    }
    

    //MARK: - TableView Data Source Delegate Methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)-> CourseTableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier(kTableViewCellIdentifier)
            as! CourseTableViewCell
        var course = courses[indexPath.row]
    
        cell.titleLabel?.text =  course.name
        
        if let firstSession = course.sessions.first {
            cell.sessionIdsLabel?.text = firstSession.name
        }

        if let firstUniversity = course.universities.first {
            cell.universityIdsLabel?.text = firstUniversity.name
        }

        if let firstCategory = course.categories.first {
            cell.categoryIdsLabel?.text = firstCategory.name
        }

        if let firstInstructor = course.instructors.first {
            cell.instructorIdsLabel?.text = firstInstructor.name
        }
        
        return cell
    }
}

