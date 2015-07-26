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
let kCourseClassName = "MUCourse"

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
    }
    
    @IBAction func fetchFromMoocApi(sender:AnyObject?)
    {

        moocApiManager.fetchCoursesFromApiWithBlock { newCourses in
            self.courses = newCourses
            dispatch_async(dispatch_get_main_queue()){
                self.tableView.reloadData()
                
                //self.moocApiManager.saveCoursesToParse(self.courses)
            }
        }
    }

    @IBAction func fetchFromParse(sender:AnyObject?)
    {
        
        var query = PFQuery(className: kCourseClassName)
        parseManager.fetchCourses(query) { (newCourses) -> Void in

            self.courses = newCourses

            dispatch_async(dispatch_get_main_queue()){
                self.tableView.reloadData()
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
            
        cell.titleLabel?.text =  courses[indexPath.row].name
        
        var course = courses[indexPath.row]
        if let sessionIds = course.sessionIds {
            cell.sessionIdsLabel?.text = "Sessions: \(sessionIds)"
        }
        
        if let universityIds = course.universityIds {
            cell.universityIdsLabel?.text = "Universities: \(universityIds)"
        }
        
        if let categoryIds = course.categoryIds {
            cell.categoryIdsLabel?.text = "Categories: \(categoryIds)"
        }
        
        if let instructorIds = course.instructorIds {
            cell.instructorIdsLabel?.text = "Instructors: \(instructorIds)"
        }
        
        return cell
    }
}

