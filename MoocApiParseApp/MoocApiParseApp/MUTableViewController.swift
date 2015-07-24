//
//  MUTableViewController.swift
//  MoocUp-ApiParseInterface
//
//  Created by Ancil on 7/22/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import UIKit
import Parse

let MUServerScheme = "https"
let MUServerHost = "api.coursera.org"
let MUServerPath = "/api/catalog.v1/"
let kMUTableViewCellIdentifier = "cell"

class MUTableViewController: UITableViewController {

    //MARK: - data members
    var courses = [Dictionary<String,AnyObject>]()
    let endpoint = "courses"
    
    let courseFields = [
        "id",
        "shortName",
        "name",
        "language",
        "photo",
        "smallIcon"
    ]

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let queryItems = getQueryItems(fromQueryNames: ["fields"])
        let url = getNSURL(fromEnpoint: endpoint, andQueryItems: queryItems)
        let data = NSData(contentsOfURL: url)!
        
        var coursesDict = NSJSONSerialization.JSONObjectWithData(
            data, options: nil, error: nil)!
            as! Dictionary<String,AnyObject>
        
        courses = coursesDict["elements"]! as! [Dictionary<String,AnyObject>]
        
        // Uncoment below only when adding new data to Parse
        //Create a MOOC object
//        var mooc1 = PFObject(className: "MUMooc")
//        mooc1.setObject("Udacity", forKey: "name")
//
//        //Create three course objects
//        var course1 = PFObject(className: "MUCourse")
//        course1["name"] = courses[3]["name"] as! String
//        course1["photo"] = courses[3]["photo"] as! String
//        course1["mooc"] = mooc1
//        
//        var course2 = PFObject(className: "MUCourse")
//        course2["name"] = courses[4]["name"] as! String
//        course2["photo"] = courses[4]["photo"] as! String
//        course2["mooc"] = mooc1
//        
//        var course3 = PFObject(className: "MUCourse")
//        course3["name"] = courses[6]["name"] as! String
//        course3["photo"] = courses[6]["photo"] as! String
//        course3["smallIcon"] = courses[6]["smallIcon"] as! String
//        course3["mooc"] = mooc1
//        
//        course1.saveInBackground()
//        course2.saveInBackground()
//        course3.saveInBackground()
        
        
        //Uncomment below to fetch from cloud the courses

        var query = PFQuery(className: "MUCourse")
        query.whereKeyExists("mooc")
        
        query.findObjectsInBackgroundWithBlock {
            ( foundCourses: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                for foundCourse in foundCourses as! [PFObject] {
                    var name = foundCourse["name"] as! String
                    var photo = foundCourse["photo"] as! String
                    println("***** Course ***** \n\tname: \(name) \n\tphoto: \(photo)")
                }
            }
            else {
                println("Error fetching parse data")
            }
        }
        
        //end of fetch
    }

    //MARK: - URL Construction Methods
    func getQueryItems(fromQueryNames names:[String])->[NSURLQueryItem]
    {
        var queryItems = [NSURLQueryItem]()
        for name in names {
            if let value = getQueryValue(forName: name) {
                queryItems.append(NSURLQueryItem(name: name, value: value))
            } else {
                assert(false,"Error in getQueryItems(fromQueryNames)")
            }
        }
        return queryItems
    }
    
    func getNSURL(fromEnpoint enpoint: String, andQueryItems items:[NSURLQueryItem])->NSURL
    {
        var components:NSURLComponents = NSURLComponents()
        components.scheme = MUServerScheme
        components.host = MUServerHost
        components.path = MUServerPath + endpoint
        components.queryItems = items
        
        if let url = components.URL{
            return url
        } else {
            assert(false,"Error in getNSURL(fromEndpoint,andQueryItems)")
        }
    }
    
    func getQueryValue(forName name:String) -> String? {
        
        switch name {
            case "fields":
                return ",".join(courseFields)
                
            default:
                return nil
        }
    }
    
    
    //MARK: - TableView Data Source Delegate Methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(kMUTableViewCellIdentifier) as! UITableViewCell
        
        var str = courses[indexPath.row]["name"] as! String
        
        cell.textLabel?.text = str
        
        return cell
    }
}

