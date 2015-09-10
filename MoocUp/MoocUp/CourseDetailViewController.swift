
import UIKit

class CourseDetailViewController: UITableViewController {

    var course: Course?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 44
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if course != nil {
            switch section {
            case 0: return 2
            default: return 1
            }
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if course != nil {
            switch section {
            case 1: return "Description"
            case 2: return "Recommended Background"
            default: return ""
            }
        } else {
            return nil
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let cell = tableView.dequeueReusableCellWithIdentifier("CourseTitleCell", forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.text = course?.name
            return cell
        case (0, 1):
            let cell = tableView.dequeueReusableCellWithIdentifier("RightDetailCell", forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.text = "Language"
            if let course = course {
                
                //TODO: Remove, just here to test a relationship
                for university in course.universities {
                    println("University: \(university.name)")
                }

                for category in course.categories {
                    println("Category: \(category.name)")
                }
                
                for session in course.sessions {
                    println("Category: \(session.name)")
                }
                
                for mooc in course.moocs {
                    println("Mooc: \(mooc.name)")
                }
                
                for instructor in course.instructors {
                    println("Mooc: \(instructor.name)")
                }
    
                for language in course.languages {
                    println("Language: \(language.name)")
                }
                
                if let language = course.languages.allObjects.first as? Language {
                cell.detailTextLabel?.text = NSLocale.currentLocale().displayNameForKey(NSLocaleIdentifier, value: language.name)
                }
            }
            return cell
        case (1, 0):
            let cell = tableView.dequeueReusableCellWithIdentifier("TextViewTableViewCell", forIndexPath: indexPath) as! TextViewTableViewCell
            cell.textView.text = course?.summary
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("TextViewTableViewCell", forIndexPath: indexPath) as! TextViewTableViewCell
            cell.textView.text = course?.prerequisite
            
            
            return cell
        }
        
    }

}
