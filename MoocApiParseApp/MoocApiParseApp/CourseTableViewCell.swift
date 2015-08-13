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
    
    
    override func awakeFromNib() {
         super.awakeFromNib()
        
        instructorIdsLabel?.textColor = UIColor.whiteColor()
        universityIdsLabel?.textColor = UIColor.whiteColor()
        sessionIdsLabel?.textColor = UIColor.whiteColor()
        categoryIdsLabel?.textColor = UIColor.whiteColor()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
    
    
}