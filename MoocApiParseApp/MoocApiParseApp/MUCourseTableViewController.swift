//
//  MUTableViewController.swift
//  MoocUp-ApiParseInterface
//
//  Created by Ancil on 7/22/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import UIKit
import Parse

let kMUTableViewCellIdentifier = "cell"
let kCourseClassName = "MUCourse"

class MUCourseTableViewController: UITableViewController {


    //MARK: - data members
    
    let moocApiManager = MUCourseraApiManager()
    let parseManager = MUParseManager()
    var courses:[MUCourse] = [MUCourse]()
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //this function gets data from api and saves up to Parse
        moocApiManager.fetchCoursesFromApiWithBlock { newCourses in
            self.courses = newCourses
            dispatch_async(dispatch_get_main_queue()){
                self.tableView.reloadData()
            }
        }
        
        //here we fetch. NOTE: Don't do both at same time
//        var query = PFQuery(className: kCourseClassName)
//        parseManager.fetchCourses(query) { (newCourses) -> Void in
//            
//            self.courses = newCourses
//            
//            dispatch_async(dispatch_get_main_queue()){
//                self.tableView.reloadData()
//            }
//        }
    }
    
    //MARK: - TableView Data Source Delegate Methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)-> MUCourseTableViewCell
    {
                
        var cell = tableView.dequeueReusableCellWithIdentifier(kMUTableViewCellIdentifier)
            as! MUCourseTableViewCell
            
        cell.titleLabel?.text =  courses[indexPath.row].name
        cell.sessionIdsLabel?.text = "Sessions: \(courses[indexPath.row].sessionIds )"
        cell.universityIdsLabel?.text = "Universities: \(courses[indexPath.row].universityIds)"
        cell.categoryIdsLabel?.text = "Categories: \(courses[indexPath.row].categoryIds)"
        cell.instructorIdsLabel?.text = "Instructors: \(courses[indexPath.row].instructorIds)"
            
        return cell
    }
}

