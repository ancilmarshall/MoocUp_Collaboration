
import UIKit

class CourseTableViewController: UITableViewController {

    var course: Course?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 44
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = course {
            switch section {
            case 0: return 2
            default: return 1
            }
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return "Description"
        case 2: return "recommended Background"
        default: return ""
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let cell = tableView.dequeueReusableCellWithIdentifier("NameTableViewCell", forIndexPath: indexPath) as! NameTableViewCell
            cell.label.text = course?.name
            return cell
        case (0, 1):
            let cell = tableView.dequeueReusableCellWithIdentifier("RightDetailCell", forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.text = "Language"
            if let course = course {
                cell.detailTextLabel?.text = NSLocale.currentLocale().displayNameForKey(NSLocaleIdentifier, value: course.language)
            }
            return cell
        case (1, 0):
            let cell = tableView.dequeueReusableCellWithIdentifier("TextViewTableViewCell", forIndexPath: indexPath) as! TextViewTableViewCell
            cell.textView.text = course?.shortDescription
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("TextViewTableViewCell", forIndexPath: indexPath) as! TextViewTableViewCell
            cell.textView.text = course?.recommendedBackground
            return cell
        }
        
    }

}
