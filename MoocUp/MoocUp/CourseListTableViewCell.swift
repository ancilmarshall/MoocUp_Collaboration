//
//  CourseListTableViewCell.swift
//  MoocUp
//
//  Created by Ancil on 8/18/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import UIKit

class CourseListTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var gradientView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel?.textColor = UIColor.whiteColor()
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
    }
}
