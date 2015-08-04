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
    var replyView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        navigationItem.title = withUser
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.reloadData()
        
        //crazy that I need to do this again here. 
        tableView.setNeedsDisplay()
        tableView.layoutIfNeeded()
        tableView.reloadData()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setTableFooterView()
    
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        replyView.removeFromSuperview()
    }
    
    
    func setTableFooterView(){
        if let frame = tabBarController?.tabBar.frame {
            replyView = UITextView(frame: CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame)))
            replyView.text = "test"
            replyView.opaque = true
            replyView.backgroundColor=UIColor.whiteColor()
            tabBarController?.tabBar.addSubview(replyView)
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var message = messages[indexPath.row]
        var returnCell = UITableViewCell()
        
        var formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeStyle = NSDateFormatterStyle.MediumStyle
        
        if let sentFrom = message["fromUser"] as? String {
            if sentFrom == PFUser.currentUser()?.username {
                let cell = tableView.dequeueReusableCellWithIdentifier(
                    "conversationReceiverCell", forIndexPath: indexPath) as! ConversationReceiverTableViewCell
                
                if let msgStr = message["message"] as? String {
                    cell.message.text = msgStr
                    cell.message.layer.cornerRadius = 5.0
                    cell.message.clipsToBounds = true
                }
                
                if let sentFrom = message["fromUser"] as? String {
                    //cell.detailTextLabel?.text = sentFrom
                }
                
                if let date = message.createdAt {
                    cell.date.text = formatter.stringFromDate(date)
                }
                returnCell = cell
                
            } else {
                
                let cell = tableView.dequeueReusableCellWithIdentifier(
                    "conversationSenderCell", forIndexPath: indexPath) as! ConversationSenderTableViewCell
                
                if let msgStr = message["message"] as? String {
                    cell.message.text = msgStr
                    cell.message.layer.cornerRadius = 5.0
                    cell.message.clipsToBounds = true
                }
                
                if let sentFrom = message["fromUser"] as? String {
                    //cell.detailTextLabel?.text = sentFrom
                }
                
                if let date = message.createdAt {
                    cell.date.text = formatter.stringFromDate(date)
                }
                
                cell.imageView?.image =
                    UIImage(named: "placeholderImage44.jpg")
                cell.imageView?.bounds = CGRectMake(0, 0, 44, 44)
                cell.imageView?.layer.cornerRadius = 22
                cell.imageView?.clipsToBounds = true
                returnCell = cell
            }
        }

        return returnCell
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
