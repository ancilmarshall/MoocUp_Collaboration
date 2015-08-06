//
//  ResizableTextView.swift
//  MoocUpClientAppDemo
//
//  Created by Ancil on 8/6/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import UIKit
/*
        NOTE & ACKNOWLEDGEMENT
    This great and concise code is taken from GitHub Nikita2k/resizableTextView
    code, and converted into Swift
*/

class ResizableTextView: UITextView {
    
//    override func updateConstraints() {
//        //println("updateConstraints - Text")
//        var contentSize = sizeThatFits(CGSizeMake(frame.size.width, CGFloat.max))
//        
//        if let allConstraints = constraints() as? [NSLayoutConstraint] {
//            for constraint in allConstraints {
//                if constraint.firstAttribute == NSLayoutAttribute.Height {
//                    constraint.constant = contentSize.height
//                    break
//                }
//            }
//        }
//        super.updateConstraints()
//    }
//    
//    override func layoutSubviews() {
//        //println("layoutSubviews - Text")
//        super.layoutSubviews()
//    }


}

extension UITextView {
    
    var trimmedText: String! {
        get {
            //Note: this is not a mutating function, so need to reassign the returned value to make
            //the underlying change
            text = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            return text
        }
        set {
            text = newValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }
    }    
}
