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
    var courses = [Course]()
    var imageSetIndicies = [Int:Bool]()
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        //must correctly use autolayout in the storyboad for this to work
        tableView.rowHeight = 200//tableView.rowHeight
        //tableView.rowHeight = UITableViewAutomaticDimension
        
        //TODO: remove the notification
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: Selector("courseImageSetNotification:"),
                name: kCourseImageSetNotificationName, object: nil)
        
        //fetchFromMoocApi(10)
        fetchFromParse(nil)
    }


    func courseImageSetNotification(notification:NSNotification) {
        
        var course = notification.object as! Course
        var index = (self.courses as NSArray).indexOfObject(course)
        var indexPath = NSIndexPath(forRow: index, inSection: 0)
        imageSetIndicies[index] = true
        println("Course at index \(index) Image Set Notification Received")
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        
    }

    @IBAction func fetchFromMoocApi(maxCourses: Int)
    {
        moocApiManager.fetchCoursesFromApiWithBlock(maxCourses) { newCourses in
            self.courses = newCourses
            dispatch_async(dispatch_get_main_queue()){
                self.tableView.reloadData()
                self.moocApiManager.saveCoursesToParse(newCourses)
            }
        }
    }
    
    @IBAction func fetchFromParse(sender:AnyObject?)
    {
        var query = PFQuery(className: kCourseClassName)
        query.includeKey("image")
        query.includeKey("moocs")
        query.includeKey("instructors")
        //query.includeKey("instructors.image")
        query.includeKey("categories")
        //query.includeKey("categories.image")
        query.includeKey("sessions")
        query.includeKey("universities")
        //query.includeKey("universities.image")
        query.limit = 100
        
        //query.orderByAscending("createdAt")
//        var categoryQuery = PFQuery(className: "Category")
//        categoryQuery.whereKey("name", equalTo: "Law")
//        query.whereKey("categories", matchesQuery: categoryQuery)
        
        query.findObjectsInBackgroundWithBlock {
            ( objects: [AnyObject]?, error: NSError?) -> Void in
            println("Parse Data Received")
            if error == nil {
                if let foundCourses = objects as? [PFObject] {
                    
                    self.courses = foundCourses.map{ Course(object: $0) }
                    self.tableView.reloadData()
                }
            }
            else {
                println("Error fetching parse data")
            }
            self.courses.map{  $0.setImage()  }
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
        
        cell.resetUI()
        
        var course = courses[indexPath.row]
    
        if imageSetIndicies[indexPath.row] == true {
            
            //println("Setting image for cell at index \(indexPath.row)")
            cell.customImageView?.image =
                UIImage(data: course.image.photoData)
            cell.customImageView?.clipsToBounds = true
            cell.customImageView?.contentMode = UIViewContentMode.ScaleAspectFill
            cell.customImageView.hidden=false
            

        }
        else {
            //println("Cell image not yet set")
            //add a temporary image view
            cell.customImageView.backgroundColor = UIColor.blueColor()
        }
        

        
        
        var gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = cell.gradientView.bounds
        gradient.colors = [UIColor.clearColor().CGColor, UIColor.blackColor().CGColor]
        
        cell.gradientView?.backgroundColor = UIColor.clearColor()
        cell.gradientView?.layer.insertSublayer(gradient, atIndex: 0)
        
        var topGradient: CAGradientLayer = CAGradientLayer()
        topGradient.frame = cell.topGradientView.bounds
        topGradient.colors = [UIColor.blackColor().CGColor, UIColor.clearColor().CGColor]
        
        cell.topGradientView?.backgroundColor = UIColor.clearColor()
        cell.topGradientView?.layer.insertSublayer(topGradient, atIndex: 0)
       
        cell.titleLabel?.text =  course.name
        
        if let firstSession = course.sessions.first {
            cell.sessionIdsLabel?.text = firstSession.name
        } else {
            cell.sessionIdsLabel?.text = ""
        }

        if let firstUniversity = course.universities.first {
            cell.universityIdsLabel?.text = firstUniversity.name
        } else {
            cell.universityIdsLabel?.text = ""
        }
        
        if let firstCategory = course.categories.first {
            cell.categoryIdsLabel?.text = firstCategory.name
        } else {
            cell.categoryIdsLabel?.text = ""
        }

        if let firstInstructor = course.instructors.first {
            cell.instructorIdsLabel?.text = firstInstructor.name
        } else {
            cell.instructorIdsLabel?.text = ""
        }
        
        cell.titleLabel.backgroundColor = UIColor.clearColor()
        cell.backgroundColor = UIColor.clearColor()
        

        return cell
    }
}

