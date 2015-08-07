
import UIKit

class CoursesListViewController: UITableViewController {
    
    var detailViewController: CourseTableViewController?
    var coursesArray = [Course]()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationItem.leftBarButtonItem = self.editButtonItem()
//        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
//        self.navigationItem.rightBarButtonItem = addButton
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? CourseTableViewController
        }

        NSURLService.loadDataFromURL(Constants.courseraURL) { [weak self] data, error in
            switch (data, error) {
            case let (.Some(data), .None):
                let array = JSONService.parse(data)

                // Parse the json and perform a closure in main queue to retrieve the result
                dispatch_async(dispatch_get_main_queue()) {
                    self?.coursesArray = array
                    self?.tableView.reloadData()
                }
            default:
                print(error)
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coursesArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        let course = coursesArray[indexPath.row]
        cell.textLabel?.text = course.name
        cell.detailTextLabel?.text = course.shortDescription
        
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Course" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! CourseTableViewController
//            let controller = segue.destinationViewController as! CourseTableViewController
            let indexPath = tableView.indexPathForSelectedRow()!
            controller.course = coursesArray[indexPath.row]
            
            // Split
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
    
}
