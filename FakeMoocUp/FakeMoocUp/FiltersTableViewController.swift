
import UIKit

class FiltersTableViewController: UITableViewController {

    let filtersArray = [["Ascending", "Descending"], ["History", "Computer sciences", "Philosophy", "Arts"]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func dismissController(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return filtersArray.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtersArray[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = filtersArray[indexPath.section][indexPath.row]
        return cell
    }
    
}
