//
//  LoginSignViewController.swift
//  MoocUpClientApp
//
//  Created by horla on 15/08/2015.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import UIKit

class LoginSignViewController: UIViewController {
    
    //widget
    @IBOutlet weak var textSign: UITextField!
    
    @IBOutlet weak var accountLabel: UILabel!
    
    @IBAction func signAction(sender: UIButton) {
    }
    
    // dissmis
    @IBAction func dissmisButton(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    


}
