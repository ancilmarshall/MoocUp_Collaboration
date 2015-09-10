
import UIKit
import Parse

let kCourseClassName = "Course"
let kCourseListCellIdentifier = "CourseListTableViewCell"

class CoursesListViewController: UITableViewController {
    
    @IBOutlet weak var LoginLogoutButton: UIBarButtonItem!
    
    var detailViewController: CourseDetailViewController?
    var courses = [Course]()
    var managedObjectContext: NSManagedObjectContext?
    var syncEngineNotificationObserver:NSObjectProtocol?
    
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
        
        if PFUser.currentUser() == nil {
            LoginLogoutButton.title = "Login"
        }
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            detailViewController = controllers[controllers.count-1].topViewController as? CourseDetailViewController
        }
        
        //set the table row height
        tableView.rowHeight = 180//tableView.rowHeight

        managedObjectContext = SDCoreDataController.sharedInstance().newManagedObjectContext()
        
        if SDSyncEngine.sharedEngine().syncInProgress == false {
            loadRecordsFromCoreData()
            self.tableView.reloadData()
        } else {
            syncEngineNotificationObserver = NSNotificationCenter.defaultCenter()
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
                var request = NSFetchRequest(entityName: kCourseClassName)
                let sortDescriptors = NSSortDescriptor(key: "createdAt", ascending: true)
                request.sortDescriptors = [sortDescriptors]
                var error = NSErrorPointer()
                
                if let courses = moc.executeFetchRequest(request, error: error) as? [Course] {
                    if error == nil {
                        self.courses = courses
                    } else {
                        println("Error fetching \(kCourseClassName) from CoreData")
                    }
                }
                println("Number of Courses: \(self.courses.count)")
            }
        }
    }

    deinit{
        if let observer = syncEngineNotificationObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
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

    
    //MARK: Navigation
    @IBAction func logout(sender: UIBarButtonItem){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        if PFUser.currentUser() == nil {
            appDelegate.toLogin()
        } else {
            PFUser.logOutInBackgroundWithBlock { (error: NSError?) -> Void in
                if (error != nil) {
                    println("Error Logging out user")
                }
                appDelegate.toLogin()
            }
        }
    }
    
    // MARK: - Rotation Support
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {

        coordinator.animateAlongsideTransition({ (context) -> Void in
            self.tableView.reloadData()
        }, completion: nil)
    }
}

