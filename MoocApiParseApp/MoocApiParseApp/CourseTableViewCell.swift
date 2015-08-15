//
//  MUCourseTableViewCell.swift
//  MoocApiParseApp
//
//  Created by Ancil on 7/25/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import Foundation
import UIKit

class CourseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var instructorIdsLabel: UILabel!
    @IBOutlet weak var universityIdsLabel: UILabel!
    @IBOutlet weak var sessionIdsLabel: UILabel!
    @IBOutlet weak var categoryIdsLabel: UILabel!
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var topGradientView: UIView!
    
    
    override func awakeFromNib() {
         super.awakeFromNib()
        
        titleLabel?.textColor = UIColor.whiteColor()
        instructorIdsLabel?.textColor = UIColor.whiteColor()
        universityIdsLabel?.textColor = UIColor.whiteColor()
        sessionIdsLabel?.textColor = UIColor.whiteColor()
        categoryIdsLabel?.textColor = UIColor.whiteColor()
    }
    
    // need to reset cell data for the cases where the cell is reused
    func resetUI(){
        
        customImageView.image = nil
        
        //remove all previous gradient layers
        if let layers = gradientView?.layer.sublayers {
            for layer in layers {
                if layer is CAGradientLayer {
                    layer.removeFromSuperlayer()
                }
            }
        }
        
        //remove all previous topGradient layers
        if let layers = topGradientView?.layer.sublayers {
            for layer in layers {
                if layer is CAGradientLayer {
                    layer.removeFromSuperlayer()
                }
            }
        }
        
    }
    
}