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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
