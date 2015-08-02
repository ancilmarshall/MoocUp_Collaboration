//
//  Utility.swift
//  MoocUpClientAppDemo
//
//  Created by Ancil on 8/2/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import UIKit

class Utility: NSObject {
   
    //MARK: - Helper functions
    static func displayAlert(viewController:UIViewController, title: String, message: String) {
        
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            
            //viewController.dismissViewControllerAnimated(true, completion: nil)
            
        })))
        
        viewController.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
}
