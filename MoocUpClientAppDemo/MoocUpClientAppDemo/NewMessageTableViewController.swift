//
//  NewMessageTableViewController.swift
//  MoocUpClientAppDemo
//
//  Created by Ancil on 8/2/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import UIKit
import Parse

class NewMessageTableViewController: UITableViewController {

    var usernames = [String]()
    var userids = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Find all users that I am following,ie where fromUser is me
        var followUserQuery = PFQuery(className: "FollowUser")
        followUserQuery.whereKey("fromUser", equalTo: PFUser.currentUser()!.objectId!)
        
        //Using the returned FollowUser objects, give me the users in the "toUsers" attribute
        var userQuery = PFUser.query()!
        userQuery.whereKey("objectId", notEqualTo: PFUser.currentUser()!.objectId!)
        userQuery.whereKey("objectId", matchesKey: "toUser", inQuery: followUserQuery)
        
        //Note: Query on userQuery to return PFUser objects so I can get username
        userQuery.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
            
            if let followers = objects as? [PFUser] {
                
                usernames = followers.map{ $0.username as! String }
                
                
                for user in followers {
                    self.usernames.append(user.username!)
                    self.userids.append(user.objectId!)
                    dispatch_async(dispatch_get_main_queue()){
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("newMessageCell", forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel?.text = usernames[indexPath.row]
        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
