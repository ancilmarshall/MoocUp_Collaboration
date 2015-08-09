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
        
        //fetchFromMoocApi(nil)
        fetchFromParse(nil)
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

    let queryLimit :Int? = 20
    
    @IBAction func fetchFromParse(sender:AnyObject?)
    {
        var query = PFQuery(className: kCourseClassName)
        query.includeKey("image")
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
                        
                        //can only perform this step if "image" is an includeKey for the query
                    
                        self.addImage(course, { (image:Image?) in
                            if let image = image {
                                newCourse.image = image
                                dispatch_async(dispatch_get_main_queue()){
                                    self.tableView.reloadData()
                                }
                            }
                        })
                        
                        self.addInstructors(course){ (instructors:[Instructor]?)  in
                            if let instructors = instructors {
                                newCourse.instructors = instructors
                                dispatch_async(dispatch_get_main_queue()){
                                    self.tableView.reloadData()
                                }
                            }
                        }
                        
                        self.addUniversities(course) { (universities:[University]?) in
                            if let universities = universities {
                                newCourse.universities = universities
                                dispatch_async(dispatch_get_main_queue()){
                                    self.tableView.reloadData()
                                }
                            }
                        }
                        
                        self.addCategories(course) { (categories:[Category]?) in
                            if let categories = categories {
                                newCourse.categories = categories
                                dispatch_async(dispatch_get_main_queue()){
                                    self.tableView.reloadData()
                                }
                            }
                        }
                        

                        self.addSessions(course) { (sessions:[Session]?) in
                            if let sessions = sessions {
                                newCourse.sessions = sessions
                                dispatch_async(dispatch_get_main_queue()){
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    
                        self.courses.append(newCourse)
                        
                        if let limit = self.queryLimit {
                            if self.courses.count == limit {
                                dispatch_async(dispatch_get_main_queue()){
                                    self.tableView.reloadData()
                                }
                            }
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
    
    
    func addInstructors(course:PFObject, _ completionHandler:(instructors: [Instructor]?)->Void) {
        
        var instructorRelation = course.relationForKey("instructors")
        var instructorQuery = instructorRelation.query()!
        instructorQuery.findObjectsInBackgroundWithBlock
        {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            var instructors = [Instructor]()
            if error == nil {
                
                if let foundInstructors = objects as? [PFObject] {
                    
                    for instructor in foundInstructors {
                        var newInstructor = Instructor()
                        newInstructor.name = instructor["name"] as! String
                        instructors.append(newInstructor)
                        
                    }
                }
            } else {
                println("Problem fetching instructors")
            }
            completionHandler(instructors: instructors)
        }
    }



    func addUniversities(course:PFObject, _ completionHandler:(universities:[University]?)->Void) {
        
        var relation = course.relationForKey("universities")
        var query = relation.query()!
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            var universities = [University]()
            if error == nil {
                
                if let foundObjects = objects as? [PFObject] {
                    
                    for object in foundObjects {
                        var newObject = University()
                        newObject.name = object["name"] as! String
                        universities.append(newObject)
                    }
                }
            } else {
                println("Problem fetching instructors")
            }
            
            completionHandler(universities:universities)
        }
        
    }
    
    func addCategories(course:PFObject, _ completionHandler:(categories:[Category]?) -> Void){
        
        var relation = course.relationForKey("categories")
        var query = relation.query()!
        query.findObjectsInBackgroundWithBlock
        {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            var categories = [Category]()
            if error == nil {
                
                if let foundObjects = objects as? [PFObject] {
                    
                    for object in foundObjects {
                        var newObject = Category()
                        newObject.name = object["name"] as! String
                        categories.append(newObject)
                    }
                }
            } else {
                println("Problem fetching instructors")
            }
            
            completionHandler(categories: categories)
        }
        
    }
    
    func addSessions(course:PFObject, _ completionHandler:(sessions:[Session]?)->Void ){
        
        var relation = course.relationForKey("sessions")
        var query = relation.query()!
        query.findObjectsInBackgroundWithBlock
        {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            var sessions = [Session]()
            
            if error == nil {
                
                if let foundObjects = objects as? [PFObject] {
                    
                    for object in foundObjects {
                        var newObject = Session()
                        newObject.name = object["name"] as! String
                        sessions.append(newObject)
                    }
                }
            } else {
                println("Problem fetching instructors")
            }
            
            completionHandler(sessions: sessions)
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

