
import UIKit
import Parse

let kCourseClassName = "Course"
let kCourseListCellIdentifier = "CourseListTableViewCell"
class CoursesListViewController: UITableViewController {
    
    var detailViewController: CourseDetailViewController?
    var courses = [Course]()
    var foundCourseObjects = [PFObject]()
    var getCoursesCurrentIndex:Int = 0
    var totalCourses = 0
    var numBatches = 0
    var getBatchCurrentIndex:Int = 0
    var fetchLimit = 5
    var fetchSkip = 0
    var totalFetched = 0
    
    //MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            detailViewController = controllers[controllers.count-1].topViewController as? CourseDetailViewController
        }
        
        //set the table row height
        tableView.rowHeight = 180//tableView.rowHeight

        //addobservers
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: Selector("courseImageSetNotification:"),
                name: kCourseCompleteNotificationName, object: nil)

        //call the connection to parse with the number of courses desired. (nil for all courses)
        fetchFromParse(20)
    }
    
    deinit{
        NSNotificationCenter.defaultCenter()
            .removeObserver(self, name: kCourseCompleteNotificationName, object: nil)
    }
    
    // MARK: - Parse Support Methods
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
        query.includeKey("instructors.image")
        query.includeKey("categories")
        query.includeKey("sessions")
        query.includeKey("universities")
        query.includeKey("universities.image")
        query.includeKey("languages")
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
    
    func fetchFromParse(maxCourses:Int?)
    {
        
        var query = PFQuery(className: kCourseClassName)
        
        query.countObjectsInBackgroundWithBlock {
            (countInt32, error) -> Void in
            
            if let maxCount = maxCourses {
                self.totalCourses = maxCount
            } else {
                self.totalCourses = Int(countInt32)
            }
            
            if (self.totalCourses > 0 && self.fetchLimit > 0) {
                
                self.fetchLimit = min(self.fetchLimit,self.totalCourses)
                
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

    
    // MARK: - Table View Data Source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCourseListCellIdentifier, forIndexPath: indexPath) as! CourseListTableViewCell
        
        cell.resetUI()
        
        let course = courses[indexPath.row]
        
        cell.customImageView?.image =
            UIImage(data: course.image.largeIconData)
        cell.customImageView?.clipsToBounds = true
        cell.customImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        
        var gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = cell.gradientView.bounds
        gradient.colors = [UIColor.clearColor().CGColor, UIColor.blackColor().CGColor]
        
        cell.gradientView?.backgroundColor = UIColor.clearColor()
        cell.gradientView?.layer.insertSublayer(gradient, atIndex: 0)
        cell.gradientView?.alpha = 1

        cell.titleLabel?.text =  course.name
        
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Course" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! CourseDetailViewController
            let indexPath = tableView.indexPathForSelectedRow()!
            controller.course = courses[indexPath.row]
            //println(courses[indexPath.row])
            
            // Split
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
    
}
