//
//  LoginSignViewController.swift
//  MoocUpClientApp
//
//  Created by horla on 15/08/2015.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import UIKit
import Parse

class LoginSignViewController: UIViewController, UITextFieldDelegate {
    
    //widget
    //UITextField
    @IBOutlet weak var userPseudoTextField: UITextField!
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPassTextField: UITextField!
    
    @IBOutlet weak var accountLabel: UILabel!
    
    
    // Sign Up Button
    @IBAction func signAction(sender: UIButton) {
            let userPseudo = userPseudoTextField.text
            let userEmail = userEmailTextField.text
            let userPassword = userPassTextField.text
            userPseudoTextField.resignFirstResponder()
        
        // Check for empty field
        if (userPseudo.isEmpty || userEmail.isEmpty || userPassword.isEmpty) {
            // Display alert message
            displayAlertMessage("All fields are required")
            return
        }
        
        // Parse Store Data
        let user:PFUser = PFUser()
        
        user.username = userPseudo
        user.password = userPassword
        user.email = userEmail
    
        user.signUpInBackgroundWithBlock { (success,error) -> Void in
            println ("send Ok")
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.toTheMooc()
        }
        
    }
    
    // dismiss Button
    @IBAction func dissmisButton(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
  
    // dismiss Keyboard
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        userPseudoTextField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Alerte Message
    func displayAlertMessage (userMessage:String) {
        var myAlert = UIAlertController (title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction (title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        
    }
    


}
