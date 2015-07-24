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

class MUTableViewController: UITableViewController {


    //MARK: - data members
    
    let moocApiManager = MUCourseraApiManager()
    let parseManager = MUParseManager()
    var courses:[MUCourse] = [MUCourse]()
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //this function gets data from api and saves up to Parse
        //moocApiManager.saveCoursesToParse( moocApiManager.fetchCoursesFromApi() )
        
        courses = moocApiManager.fetchCoursesFromApi()
        tableView.reloadData()
        
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(kMUTableViewCellIdentifier) as! UITableViewCell
        
        var str = courses[indexPath.row].name
        
        cell.textLabel?.text = str
        //cell.detailTextLabel?.text = " \(courses[indexPath.row].instructorIds?.first)"
        cell.detailTextLabel?.text = "\(courses[indexPath.row].sessionIds?.first)"
        return cell
    }
}

