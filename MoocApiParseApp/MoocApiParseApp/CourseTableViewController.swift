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
let kInitialFetchCompleteNotificationName = "InitialFetchCompleteNotification"

class CourseTableViewController: UITableViewController {


    //MARK: - data members
    
    let moocApiManager = CourseraApiManager()
    let parseManager = ParseManager()
    var courses = [Course]()
    var foundCourseObjects = [PFObject]()
    var getCoursesCurrentIndex:Int = 0
    var totalCourses = 0
    var numBatches = 0
    var getBatchCurrentIndex:Int = 0
    var fetchLimit = 50
    var fetchSkip = 0
    var totalFetched = 0
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        //must correctly use autolayout in the storyboad for this to work
        tableView.rowHeight = 200//tableView.rowHeight
        //tableView.rowHeight = UITableViewAutomaticDimension
        
        //addobservers
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: Selector("courseImageSetNotification:"),
                name: kCourseImageSetNotificationName, object: nil)
        
        
        //fetchFromMoocApi(100)
        fetchFromParse(nil)
    }

    func getNextCourse(){
        
        if getCoursesCurrentIndex < self.foundCourseObjects.count {
            var currentCourseObject = self.foundCourseObjects[getCoursesCurrentIndex]
            Course(object:currentCourseObject) // asynchronous
        }
        else if getBatchCurrentIndex < numBatches {
            getCoursesCurrentIndex = 0
            getBatchCurrentIndex++
            fetchSkip = fetchLimit*getBatchCurrentIndex
            
            totalFetched = totalFetched+fetchLimit
            
            var rem = totalCourses-totalFetched
            fetchLimit = min(rem,fetchLimit)
            
            if fetchLimit > 0 {
                getNextBatch()
            }
        }
    }
    
    func courseImageSetNotification(notification:NSNotification) {
        
        //Get course
        var course = notification.object as! Course
        courses.append(course)
        
        var indexPath = NSIndexPath(forRow: courses.count-1, inSection: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        
        println("Course Notification Received: \(courses.count)")
        
        getCoursesCurrentIndex++
        getNextCourse()
        
    }
    
    func getNextBatch(){
        println("Getting Batch \(getBatchCurrentIndex+1)")
        
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
        query.orderByAscending("createdAt")
        query.limit = fetchLimit
        query.skip = fetchSkip
        
        query.findObjectsInBackgroundWithBlock {
            ( objects: [AnyObject]?, error: NSError?) -> Void in
            println("data received")
            if error == nil {
                if let foundObjects = objects as? [PFObject] {
                    
                    self.foundCourseObjects = foundObjects
                    self.getNextCourse()
                }
            }
            else {
                println("Error fetching parse data")
            }
        }
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
        
        query.countObjectsInBackgroundWithBlock {
            (countInt32, error) -> Void in
            self.totalCourses = Int(countInt32)
            
            if (self.totalCourses > 0 && self.fetchLimit > 0) {
        
                self.numBatches = ( self.totalCourses % self.fetchLimit == 0 )
                    ? self.totalCourses/self.fetchLimit
                    : self.totalCourses/self.fetchLimit+1
            
                self.getNextBatch()
            }
            else {
                println("Total Courses and Query Fetch Limit must be greater than zero")
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
        
        cell.resetUI()
        
        var course = courses[indexPath.row]
        
        //println("Setting image for cell at index \(indexPath.row)")
        cell.customImageView?.image =
            UIImage(data: course.image.largeIconData)
        cell.customImageView?.clipsToBounds = true
        cell.customImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        cell.customImageView.hidden=false
        
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

