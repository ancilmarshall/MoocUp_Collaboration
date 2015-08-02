//
//  ViewController.swift
//  MoocUpClientAppDemo
//
//  Created by Ancil on 7/31/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import UIKit
import Parse
import Foundation

class LogInViewController: UIViewController {

    
    var logInActive = true
    
    @IBOutlet var username: UITextField!
    
    @IBOutlet var password: UITextField!
    
    @IBOutlet var signupButton: UIButton!
    
    @IBOutlet var registeredText: UILabel!
    
    @IBOutlet var loginButton: UIButton!
    
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // if i'm already logged in, bypass the login view and go directly to users table view
//        if (PFUser.currentUser() != nil) {
//            
//            var storyboardName = "Main";
//            var viewControllerID = "clientAppMainView";
//            var storyboard = UIStoryboard(name: storyboardName, bundle: nil)
//            var controller = storyboard.instantiateViewControllerWithIdentifier(viewControllerID) as! UIViewController
//            
//            UIApplication.sharedApplication().delegate?.window?!.rootViewController = controller
//
//        }

    }
    

    @IBAction func logIn(sender: AnyObject) {
        
        if username.text == "" || password.text == "" {
            
            Utility.displayAlert(self,title: "Error in form", message: "Please enter a username and password")
            
        } else {
            
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            var errorMessage = "Please try again later"
            
            if logInActive == false {
                
                var user = PFUser()
                user.username = username.text
                user.password = password.text
                
                user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if error == nil {
                        
                        // Signup successful
                        
                        self.performSegueWithIdentifier("login", sender: self)
                        
                        
                    } else {
                        
                        errorMessage = error!.localizedDescription
                        
                        Utility.displayAlert(self,title: "Failed SignUp", message: errorMessage)
                        
                    }
                    
                })
                
            } else {
                
                PFUser.logInWithUsernameInBackground(username.text!, password: password.text!, block:
                    { (user, error) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if user != nil {
                        
                        // Logged In!
                        
                        self.performSegueWithIdentifier("login", sender: self)
                        
                        
                    } else {
                        
                        errorMessage = error!.localizedDescription
                        
                        Utility.displayAlert(self, title: "Failed Login", message: errorMessage)
                        
                    }
                    
                })
                
            }
            
        }
        
    }
    
    
    @IBAction func signUp(sender: AnyObject) {
        
        if logInActive == true {
            
            signupButton.setTitle("Log In", forState: UIControlState.Normal)
            
            registeredText.text = "Already registered?"
            
            loginButton.setTitle("Sign Up", forState: UIControlState.Normal)
            
            logInActive = false
            
        } else {
            
            signupButton.setTitle("Sign Up", forState: UIControlState.Normal)
            
            registeredText.text = "Not registered?"
            
            loginButton.setTitle("Log In", forState: UIControlState.Normal)
            
            logInActive = true
            
        }
        
        
    }

    //prevent the segue from happening automatically so I can show and alert if needed
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        return false
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser() != nil {
            
            self.performSegueWithIdentifier("login", sender: self)
            
            
        }

    }
    
    @IBAction func logout(segue:UIStoryboardSegue)
    {
        
        PFUser.logOutInBackgroundWithBlock { (error) -> Void in
            var storyboardName = "Main";
            var viewControllerID = "logInViewController";
            var storyboard = UIStoryboard(name: storyboardName, bundle: nil)
            var controller = storyboard.instantiateViewControllerWithIdentifier(viewControllerID) as! UIViewController
            
            UIApplication.sharedApplication().delegate?.window?!.rootViewController = controller
            
        }
    }


    
//    //MARK: - Helper functions
//    func displayAlert(title: String, message: String) {
//        
//        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
//        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
//            
//            self.dismissViewControllerAnimated(true, completion: nil)
//            
//        })))
//        
//        self.presentViewController(alert, animated: true, completion: nil)
//        
//    }


}

