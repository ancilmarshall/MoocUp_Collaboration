
import UIKit
import Parse

let kCourseClassName = "Course"
let kCourseListCellIdentifier = "CourseListTableViewCell"
class CoursesListViewController: UITableViewController {
    
    var detailViewController: CourseDetailViewController?
    var courses = [Course]()
    
    var managedObjectContext: NSManagedObjectContext?
    var syncEngine: SDSyncEngine?
    
    var foundCourseObjects = [PFObject]()
    var getCoursesCurrentIndex = 0
    var totalCourses = 0
    var numBatches = 0
    var getBatchCurrentIndex = 0
    var fetchLimit = 20
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

        syncEngine = SDSyncEngine.sharedEngine()
        managedObjectContext = SDCoreDataController.sharedInstance().newManagedObjectContext()
        
        if !syncEngine!.syncInProgress {
            loadRecordsFromCoreData()
            self.tableView.reloadData()
        } else {
            NSNotificationCenter.defaultCenter()
                .addObserverForName("SDSyncEngineSyncCompleted", object: nil, queue: nil) {
                    (NSNotification note)-> Void in
                    self.loadRecordsFromCoreData()
                    self.tableView.reloadData()
            }
        }
    }
    
    func loadRecordsFromCoreData()
    {
        if let moc = managedObjectContext{
            moc.performBlockAndWait{
                moc.reset()
                let request = NSFetchRequest(entityName: "Course")
                let sortDescriptors = NSSortDescriptor(key: "createdAt", ascending: true)
                request.sortDescriptors = [sortDescriptors]
                var error = NSErrorPointer()
                
                //Do some error checking before explicit as!
                self.courses = moc.executeFetchRequest(request, error: error) as! [Course]
                println("Number of Courses: \(self.courses.count)")
                //Do some error checking after the fetch request
            }
        }
    }

    
    deinit{
//        NSNotificationCenter.defaultCenter()
//            .removeObserver(self, name: kCourseCompleteNotificationName, object: nil)
    }
    
    // MARK: - Parse Support Methods
    
    func resetParseFetchCounters() {
        getCoursesCurrentIndex = 0
        getBatchCurrentIndex = 0
        totalFetched = 0
        fetchSkip = 0
    }
    
    func getNextCourse(){

        var currentCourseObject = self.foundCourseObjects[getCoursesCurrentIndex++]
        //Course(object:currentCourseObject) // asynchronous

    }
    
    func courseCompleteNotification(notification:NSNotification) {
        
        //Get course
        var course = notification.object as! Course
        var index = Int()
        if contains(courses,course) {
            index = (courses as NSArray).indexOfObject(course)
            var range = Range<Int>(start: index, end: index+1)
            courses.replaceRange(range, with: [course])
            var indexPath = NSIndexPath(forRow: courses.count-1, inSection: 0)
            //tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            tableView.reloadData()
        }
        else {
            courses.append(course)
            index = courses.count-1
            var indexPath = NSIndexPath(forRow: index, inSection: 0)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        
        println("Course Notification Received: \(index+1)")
 
        if getCoursesCurrentIndex < self.foundCourseObjects.count {
            getNextCourse()
            
        } else {
            courseBatchComplete()
        }
    }
    
    func courseBatchComplete() {
        
        if !includeImages {
        // repeat the current branch (by not incrementing the counter)
            includeImages = true
            getCoursesCurrentIndex = 0
            getNextBatch()
        
        } else {
            
            getBatchCurrentIndex++
            includeImages = false
         
            if getBatchCurrentIndex < numBatches {
                
                getCoursesCurrentIndex = 0
                
                fetchSkip = fetchLimit*getBatchCurrentIndex
                totalFetched = totalFetched+fetchLimit
                
                var rem = totalCourses-totalFetched
                fetchLimit = min(rem,fetchLimit)
                
                getNextBatch()
                
            } else {
                println("done")
                resetParseFetchCounters()
            }
        }
    }
    
    var includeImages = false
    
    func courseQueryNoImages() -> PFQuery {
        var query = PFQuery(className: kCourseClassName)
        query.includeKey("moocs")
        query.includeKey("instructors")
        query.includeKey("categories")
        query.includeKey("sessions")
        query.includeKey("universities")
        query.includeKey("languages")
        query.orderByAscending("createdAt")
        return query
    }
    
    func getNextBatch(){
        
        println("Getting Batch \(getBatchCurrentIndex+1)")
        
        var query = courseQueryNoImages()
        if includeImages {
            query.includeCourseImage()
        }
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
        
        cell.customImageView?.image = UIImage(data: course.image.photoData)
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

extension PFQuery {
    func includeCourseImage() {
        self.includeKey("image")
    }
}
