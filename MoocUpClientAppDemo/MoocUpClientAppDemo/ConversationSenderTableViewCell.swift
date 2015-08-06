//
//  ConversationSenderTableViewCell.swift
//  MoocUpClientAppDemo
//
//  Created by Ancil on 8/3/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import UIKit

class ConversationSenderTableViewCell: UITableViewCell {

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var message: UITextView!
    
//    override func layoutSubviews() {
//        println("layout subviews")
//        
//        var pins = contentView.constraints()
//        
//        if let allConstraints = contentView.constraints() as? [NSLayoutConstraint] {
//            for constraint in allConstraints {
//                if constraint.firstAttribute == NSLayoutAttribute.Bottom {
//                    println("Bottom is \(constraint.constant) " )
//                    break
//                }
//            }
//        }
//
//        super.layoutSubviews()
//    }
}

