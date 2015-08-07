
import UIKit

class ContactsTableViewController: UITableViewController {
    
    var detailViewController: MessagesTableViewController?
    let contactsArray = ["Ancil", "Laurent B.", "Laurent F.", "Olivier", "Sabine", "Imanou"]
    
    
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
            self.detailViewController = controllers[controllers.count-1].topViewController as? MessagesTableViewController
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = contactsArray[indexPath.row]
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Message" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! MessagesTableViewController
            let indexPath = tableView.indexPathForSelectedRow()!
            controller.contact = contactsArray[indexPath.row]
            
            // Split
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
    
}
