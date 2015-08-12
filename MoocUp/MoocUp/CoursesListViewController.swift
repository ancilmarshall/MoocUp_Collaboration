
import UIKit
import Parse

class CoursesListViewController: UITableViewController {
    
    var detailViewController: CourseDetailViewController?
    var courses = [Course]()
    
    
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
        
        var query = PFQuery(className: "Course")
        query.includeKey("image")
        query.includeKey("moocs")
        query.includeKey("instructors")
        query.includeKey("instructors.image")
        query.includeKey("categories")
        query.includeKey("categories.image")
        query.includeKey("sessions")
        query.includeKey("universities")
        query.includeKey("languages")
        query.limit = 10
        
        //query.orderByAscending("createdAt")
        
        //        var categoryQuery = PFQuery(className: "Category")
        //        categoryQuery.whereKey("name", equalTo: "Law")
        //        query.whereKey("categories", matchesQuery: categoryQuery)
        
        query.findObjectsInBackgroundWithBlock {
            ( objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                if let foundCourses = objects as? [PFObject] {
                    self.courses = foundCourses.map{ Course(object: $0) }
                    self.tableView.reloadData()
                }
                else {
                    println("No courses found from Parse")
                }
            }
            else {
                println("Error fetching parse data")
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        let course = courses[indexPath.row]
        cell.textLabel?.text = course.name
        cell.detailTextLabel?.text = course.summary
        
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
