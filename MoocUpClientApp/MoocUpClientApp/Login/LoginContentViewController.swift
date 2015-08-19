//
//  LoginContentViewController.swift
//  MoocUpClientApp
//
//  Created by horla on 14/08/2015.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import UIKit

class LoginContentViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var testTutorial: UILabel!
    
    var imageFileName: String!
    var pageIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Declare propertie of UIimageView
        imageView.image = UIImage (named: imageFileName)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
