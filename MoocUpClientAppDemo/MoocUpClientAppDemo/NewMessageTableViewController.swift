//
//  NewMessageTableViewController.swift
//  MoocUpClientAppDemo
//
//  Created by Ancil on 8/2/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import UIKit
import Parse

class NewMessageTableViewController: UITableViewController, UITextFieldDelegate {

    var usernames = [String]()
    
    @IBOutlet weak var messageInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Find all users that I am following,ie where fromUser is me
        var followUserQuery = PFQuery(className: "FollowUser")
        followUserQuery.whereKey("fromUser", equalTo: PFUser.currentUser()!.username!)
        
        //Using the returned FollowUser objects, give me the users in the "toUsers" attribute
        var userQuery = PFUser.query()!
        userQuery.whereKey("username", notEqualTo: PFUser.currentUser()!.username!)
        userQuery.whereKey("username", matchesKey: "toUser", inQuery: followUserQuery)
        
        //Note: Query on userQuery to return PFUser objects so I can get username
        userQuery.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
            
            if let followers = objects as? [PFUser] {
                if followers.count > 0 {
                    self.usernames = followers.map { $0.username!}
                    dispatch_async(dispatch_get_main_queue()){
                        self.tableView.reloadData()
                        
                    }
                } else {
                    Utility.displayAlert(self, title: "No Followers", message: "Can only send messages to your followers")
                    
                    
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
        
        
        if indexPath == sendToUserIndexPath {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        send(nil)
        
        return false
    }
    
    var sendToUserIndexPath:NSIndexPath?
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        sendToUserIndexPath = indexPath
        tableView.reloadData()
        
    }
        
    @IBAction func send(sender:AnyObject?) {
        
        messageInput.resignFirstResponder()
        
        if messageInput.text == "" {
            Utility.displayAlert(self, title: "Empty Message", message: "Please enter a message in the message text field")
        } else if sendToUserIndexPath == nil {
            Utility.displayAlert(self, title: "No receipient", message: "Please select one of your followers")
        }
        else {
            //create message PFObject
            var message = PFObject(className: "Message")
            message["fromUser"] = PFUser.currentUser()?.username!
            message["toUser"] = usernames[sendToUserIndexPath!.row]
            message["message"] = messageInput.text
            
            message.saveInBackgroundWithBlock { (success, error) -> Void in
                
                if error != nil {
                    println("Error saving message")
                }
                self.dismissViewControllerAnimated(true, completion: nil)
                
            }
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func cancel(sender:AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }

}
