//
//  LoginCustomButton.swift
//  MoocUpClientApp
//
//  Created by horla on 15/08/2015.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import UIKit

class LoginCustomButton: UIButton{

    required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.layer.borderColor = UIColor.whiteColor().CGColor
    self.layer.borderWidth = 0.5
    //self.backgroundColor = UIColor.blueColor()
    self.tintColor = UIColor.whiteColor()
    }

}
