//
//  LoginSignViewSegue.swift
//  MoocUpClientApp
//
//  Created by ls on 03/09/2015.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import UIKit

class LoginSignViewSegue: UIStoryboardSegue {
    
    override func perform() {
        // Assign the source and destination views to local variables.
        var sourceView = self.sourceViewController.view as UIView!
        var destinationView = self.destinationViewController.view as UIView!
        
        destinationView.backgroundColor = UIColor.clearColor()
        
        // Create Image context
        UIGraphicsBeginImageContextWithOptions(sourceView.bounds.size, false, 0)
        
        sourceView.drawViewHierarchyInRect(sourceView.bounds, afterScreenUpdates: true)
        // Get Screenshot UIImage context from view
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
//MARK: - Blurr
        
       // add screen shoot view to destinationView
       let screenshotview = UIImageView (image: screenshot)
       screenshotview.frame = CGRectMake(0.0,0.0, screenshot.size.width, screenshot.size.height)
        destinationView.insertSubview(screenshotview, atIndex: 0)
        
        // Blur destinationView and place in background
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        blurView.frame = destinationView.bounds
        destinationView.insertSubview(blurView, atIndex: 1)
        
        // Get the screen width and height.
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        // Specify the initial position of the destination view.
        destinationView.frame = CGRectMake(0.0, screenHeight, screenWidth, screenHeight)
        // Access the app's key window and insert the destination view above the current (source) one.
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(destinationView, aboveSubview: sourceView)
        
        
        // Animate the transition.
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            sourceView.frame = CGRectOffset(sourceView.frame, 0.0, -screenHeight)
            destinationView.frame = CGRectOffset(destinationView.frame, 0.0, -screenHeight)
            
            }) { (Finished) -> Void in
                self.sourceViewController.presentViewController(self.destinationViewController as! UIViewController,
                    animated: false,
                    completion: nil)
        }
    }
    
}
