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

