//
//  ConversationTableViewController.swift
//  MoocUpClientAppDemo
//
//  Created by Ancil on 8/2/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import UIKit
import Parse

class ConversationTableViewController: UITableViewController {

    var withUser =  String()
    var messages =  [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = withUser
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("conversationCell", forIndexPath: indexPath) as! UITableViewCell

        var message = messages[indexPath.row]
        if let msgStr = message["message"] as? String {
            cell.textLabel?.text = msgStr
        }
        
        if let sentFromStr = message["fromUser"] as? String {
            cell.detailTextLabel?.text = sentFromStr
        }
        
        return cell
    }
    
    
    //MARK: - Helper function
    func conversationWith(msg: PFObject) -> String{
        
        var withUserId = String()
        var myUserId = PFUser.currentUser()!.username!
        let fromUserId = msg["fromUser"] as! String
        let toUserId = msg["toUser"] as! String
        if myUserId == fromUserId {
            withUserId = toUserId
        } else {
            withUserId = fromUserId
        }
        return withUserId
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
