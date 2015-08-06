//
//  ConversationTableViewController.swift
//  MoocUpClientAppDemo
//
//  Created by Ancil on 8/2/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import UIKit
import Parse

class ConversationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate {

    var withUser =  String()
    var messages =  [PFObject]()
    var formatter = NSDateFormatter()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newMessageEntryView: ResizableView!
    @IBOutlet weak var newMessageTextView: ResizableTextView!
    @IBOutlet weak var sendButton: UIButton!
    
    let kNewMessagePlaceholderText = "Say Something nice"

    override func viewDidLoad() {
        super.viewDidLoad()
                
        navigationItem.title = withUser

        //TODO: still not happy with the fact that I need to hard code the estimate row height
        tableView.estimatedRowHeight = 100//tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.reloadData()
        
        //crazy that I need to do this again here. 
        //TODO: get rid of needing to do this... this does not make sense!
        tableView.setNeedsDisplay()
        tableView.layoutIfNeeded()
        tableView.reloadData()
        
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: messages.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        
        sendButton.layer.cornerRadius = 10.0
        sendButton.clipsToBounds = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true;
        
        //setup keyboard notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillAppear:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillDisappear:"), name: UIKeyboardWillHideNotification, object: nil)

        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: messages.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.hidden = false;
        
        
        
        
        //must remove self from notification center when view disappears
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)

    }
    
    
    //MARK:- Keyboard Notifications
    func keyboardWillAppear(notification: NSNotification){
        if let userInfo = notification.userInfo as? Dictionary<String,AnyObject>  {
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
            let keyboardheight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height
            
            if let height = keyboardheight {
                if let duration = animationDuration {
                    UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                        
                        //get the screen size
                        let screenHeight = UIScreen.mainScreen().bounds.size.height
                        self.view.frame.size.height = screenHeight - height
                        self.view.setNeedsLayout()
                        self.view.layoutIfNeeded()
                        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
                        }, completion: nil)
                }
            }
        }
    }
    
    func keyboardWillDisappear(notification: NSNotification){
        if let userInfo = notification.userInfo as? Dictionary<String,AnyObject>  {
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
            let keyboardheight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height
            
            if let height = keyboardheight {
                //get the screen size
                let screenHeight = UIScreen.mainScreen().bounds.size.height
                self.view.frame.size.height = screenHeight
                self.view.setNeedsLayout()
                if (self.newMessageTextView.text == ""){
                    self.resetNewMessageTextView()
                }
                
                if let duration = animationDuration {
                    UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                        self.view.layoutIfNeeded()
                        }, completion: nil)
                }
            }
        }
    }
    
    //MARK:- Tap Gesture
    @IBAction func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Ended {
            newMessageTextView.resignFirstResponder()
        }
    }
    
    //MARK:- Send new message

    @IBAction func send(sender: UIButton) {
        
        newMessageTextView.resignFirstResponder()
        
        if (newMessageTextView.text != "" && inMiddleOfEditingNewMessage==true) {
        
            //create message PFObject
            var message = PFObject(className: "Message")
            message["fromUser"] = PFUser.currentUser()?.username!
            message["toUser"] = withUser
            message["message"] = newMessageTextView.text
            
            message.saveInBackgroundWithBlock { (success, error) -> Void in
                
                if error != nil {
                    println("Error saving message")
                } else {
                    self.resetNewMessageTextView()
                    self.messages.append(message)
                    self.tableView.reloadData()
                    self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)

                }
            }
        }
        inMiddleOfEditingNewMessage = false
    }
    
    
    //MARK:- Text Field Delegate
    var inMiddleOfEditingNewMessage = false
    
    func textViewDidBeginEditing(textView: UITextView) {
        if (inMiddleOfEditingNewMessage == false) {
            newMessageTextView.textColor = UIColor.blackColor()
            newMessageTextView.text = ""
            inMiddleOfEditingNewMessage = true
        }
    }
    
    func resetNewMessageTextView () {
        inMiddleOfEditingNewMessage = false
        newMessageTextView.textColor = UIColor.lightGrayColor()
        newMessageTextView.text = kNewMessagePlaceholderText
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var message = messages[indexPath.row]
        var returnCell = UITableViewCell()
        
        
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
                    //TODO: Use Time or Date depending on how long ago message was sent
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
