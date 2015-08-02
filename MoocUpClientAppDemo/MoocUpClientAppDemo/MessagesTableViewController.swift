//
//  MessagesTableViewController.swift
//  MoocUpClientAppDemo
//
//  Created by Ancil on 8/2/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import UIKit
import Parse

class MessagesTableViewController: UITableViewController {
    
    var messages = Dictionary<String,[PFObject]>()
    var conversationMessages = [PFObject]()
    var refresher: UIRefreshControl!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        
        self.tableView.addSubview(refresher)
        
        //refresh()

    }
    
    func refresh() {
        
        conversationMessages.removeAll(keepCapacity: true)
        messages.removeAll(keepCapacity: true)
        
        var messagesFromMeQuery = PFQuery(className: "Message")
        messagesFromMeQuery.whereKey("fromUser", equalTo: PFUser.currentUser()!.username!)
        
        var messagesToMeQuery = PFQuery(className: "Message")
        messagesToMeQuery.whereKey("toUser", equalTo: PFUser.currentUser()!.username!)
        
        var query = PFQuery.orQueryWithSubqueries([messagesFromMeQuery, messagesToMeQuery])
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError? ) -> Void in
            
            if error == nil {
                //success
                if let objects = objects as? [PFObject] {
                    
                    for object in objects {
                        
                        //determine who I'm having the conversation with
                        //can be in either the "fromUser" or "toUser" attribute
                        var withUserId = self.conversationWith(object)
                        
                        if self.messages[withUserId] != nil {
                            self.messages[withUserId]!.append(object)
                        } else {
                            self.messages[withUserId] = [object]
                        }
                    }
                    self.tableView.reloadData()
                }
            } else {
                println("Error finding Message objects")
            }
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
            refresh()
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("messagesCell", forIndexPath: indexPath) as! UITableViewCell

        let messagesKeys = (messages as NSDictionary).allKeys as! [String]
        var messageArray = messages[messagesKeys[indexPath.row]]
        var mostRecentMessage = messageArray?.first!
        
        if let msg = mostRecentMessage {
            var msgStr = msg["message"] as! String
            cell.textLabel?.text = msgStr
            cell.detailTextLabel?.text = conversationWith(msg)
        }
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is ConversationTableViewController {
            var destVC = segue.destinationViewController as! ConversationTableViewController
            destVC.messages = conversationMessages
            
            //find who this conversation is with
            destVC.withUser = conversationWith(conversationMessages.first!)
            
        }
        
    }
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "showConversation" {
            return false
        } else {
            return true
        }
        
    }
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let messagesKeys = (messages as NSDictionary).allKeys as! [String]
        conversationMessages = messages[messagesKeys[indexPath.row]]!
        
        performSegueWithIdentifier("showConversation", sender: self)
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

    


}
