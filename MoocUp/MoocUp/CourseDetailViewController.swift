
import UIKit
import CoreData

class CourseDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var course: Course?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var courseNameView: CourseNameView!
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Course"
        //tableView.backgroundColor = UIColor(red: 210/255, green: 51/255, blue: 35/255, alpha: 1) // .whiteColor()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
        
        if let course = course, image = UIImage(data: course.image.photoData) {
            courseNameView.imageView.image = image
        }
        // Set course name
        if let course = course, courseNameView = tableView.tableHeaderView as? CourseNameView {
            courseNameView.label.text = course.name
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Redraw tableViewHeader
        if let courseNameView = tableView.tableHeaderView as? CourseNameView {
            courseNameView.label.font = .preferredFontForTextStyle(UIFontTextStyleHeadline)
            let height = courseNameView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
            courseNameView.frame.size = CGSize(width: courseNameView.bounds.width, height: height)
            tableView.tableHeaderView = courseNameView
            courseNameView.gradientView.setNeedsLayout()
            courseNameView.gradientView.layoutIfNeeded()
        }
    }
    
    // MARK: - TableView datasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if course != nil {
            switch section {
            case 0: return course?.languages.allObjects.count ?? 0
            default: return 1
            }
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if course != nil {
            switch section {
            case 0:
                if course?.languages.allObjects.count == nil || course?.languages.allObjects.count == 0 {
                    return nil
                } else {
                    return "Language"
                }
            case 1: return "Description"
            case 2: return "Recommended Background"
            default: return ""
            }
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, _):
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.font = .preferredFontForTextStyle(UIFontTextStyleCaption1)
            if let language = course!.languages.allObjects[indexPath.row] as? Language {
                cell.textLabel?.text = language.name
//                cell.textLabel?.text = NSLocale.currentLocale().displayNameForKey(NSLocaleIdentifier, value: language.name)
            }
            return cell
        case (1, 0):
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.font = .preferredFontForTextStyle(UIFontTextStyleCaption1)
            cell.textLabel?.numberOfLines = 0
            
            cell.textLabel?.font = .preferredFontForTextStyle(UIFontTextStyleFootnote)
            let encodedData = course!.summary.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            let attributedOptions = [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute : NSUTF8StringEncoding] as [String : AnyObject]
            
            var error: NSError?
            let attributedString = NSAttributedString(data: encodedData!, options: attributedOptions, documentAttributes: nil, error: &error)
            if let error = error {
                println(error.localizedDescription)
            } else {
                //(data: encodedData!, options: attributedOptions, documentAttributes: nil)
                let characterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
                let components = attributedString?.string.componentsSeparatedByCharactersInSet(characterSet).filter {!isEmpty($0)}
                if let components = components {
                    cell.textLabel?.text = join(" ", components)
                }
            }

//            cell.textLabel?.text = course!.summary
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.font = .preferredFontForTextStyle(UIFontTextStyleCaption1)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = course!.prerequisite
            return cell
        }
        
    }
    
}
