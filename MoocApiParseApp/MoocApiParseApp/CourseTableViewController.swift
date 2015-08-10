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

    let queryLimit :Int = 100
    
    @IBAction func fetchFromParse(sender:AnyObject?)
    {
        var query = PFQuery(className: kCourseClassName)
        query.includeKey("image")
        query.includeKey("moocs")
        query.includeKey("instructors")
        query.includeKey("categories")
        query.includeKey("sessions")
        query.includeKey("universities")
        query.limit = queryLimit
        query.orderByAscending("createdAt")
        
        var categoryQuery = PFQuery(className: "Category")
        categoryQuery.whereKey("name", equalTo: "Law")
        
        query.whereKey("categories", matchesQuery: categoryQuery)
        
        query.findObjectsInBackgroundWithBlock {
            ( objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                if let foundCourses = objects as? [PFObject] {
                    
                    self.courses = foundCourses.map{ Course(object: $0) }
                    
                    for course in self.courses {
                        
                        for category in course.categories {
                            if category.name == "Law"{
                                println("Law")
                            }
                        
                        }
                    }
                    
                    
                    dispatch_async(dispatch_get_main_queue()){
                        self.tableView.reloadData()
                    }
                }
            }
            else {
                println("Error fetching parse data")
            }
        }
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

