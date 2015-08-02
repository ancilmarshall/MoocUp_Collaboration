//
//  UsersTableViewController.swift
//  MoocUpClientAppDemo
//
//  Created by Ancil on 8/1/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import UIKit
import Parse

class UsersTableViewController: UITableViewController {

    var usernames = [""]
    var isFollowing = ["":false]
    
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refresher = UIRefreshControl()
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        
        self.tableView.addSubview(refresher)
        
        refresh()
        
        navigationItem.title = PFUser.currentUser()?.username

    }
    
    func refresh() {
        
        var query = PFUser.query()
        
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if let users = objects {
                
                self.usernames.removeAll(keepCapacity: true)
                self.isFollowing.removeAll(keepCapacity: true)
                
                for object in users {
                    
                    if let user = object as? PFUser {
                        
                        if user.objectId! != PFUser.currentUser()?.objectId {
                            
                            self.usernames.append(user.username!)
                            
                            var query = PFQuery(className: "FollowUser")
                            
                            query.whereKey("fromUser", equalTo: PFUser.currentUser()!.username!)
                            query.whereKey("toUser", equalTo: user.username!)
                            
                            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                                
                                if let objects = objects {
                                    
                                    if objects.count > 0 {
                                        
                                        self.isFollowing[user.username!] = true
                                        
                                    } else {
                                        
                                        self.isFollowing[user.username!] = false
                                        
                                    }
                                }
                                
                                if self.isFollowing.count == self.usernames.count {
                                    
                                    self.tableView.reloadData()
                                    
                                    self.refresher.endRefreshing()
                                    
                                }
                                
                                
                            })

                        }
                    }
                }
            }
        })
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return usernames.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("userTableViewCell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = usernames[indexPath.row]
        
        let followedObjectId = usernames[indexPath.row]
        
        if isFollowing[followedObjectId] == true {
        
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        
        return cell
    }
    
    
    
    //MARK: - Table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        let followedObjectId = usernames[indexPath.row]
        
        if isFollowing[followedObjectId] == false {
            
            isFollowing[followedObjectId] = true
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            var following = PFObject(className: "FollowUser")
            following["toUser"] = usernames[indexPath.row]
            following["fromUser"] = PFUser.currentUser()?.username
            
            following.saveInBackgroundWithBlock({ (success, error) -> Void in
                
                
            })
            
        } else {
            
            isFollowing[followedObjectId] = false
            
            cell.accessoryType = UITableViewCellAccessoryType.None
            
            var query = PFQuery(className: "FollowUser")
            
            query.whereKey("fromUser", equalTo: PFUser.currentUser()!.username!)
            query.whereKey("toUser", equalTo: usernames[indexPath.row])
            
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                
                if let objects = objects as? [PFObject]{
                    
                    for object in objects {
                        
                        object.deleteInBackgroundWithBlock { (success, error) -> Void in
                            
                            
                            
                        }
                        
                    }
                }
            })
        }
    }
}
