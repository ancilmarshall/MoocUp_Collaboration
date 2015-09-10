
import UIKit

class CourseNameView: UIView {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.clipsToBounds = true
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Label
        label.textColor = .whiteColor()
        label.numberOfLines = 0
        label.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Vertical) // UILayoutPriorityRequired
        //gradientView.layer.needsDisplayOnBoundsChange = true // how to use this property?
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.preferredMaxLayoutWidth = label.bounds.width        
        resetUI()
    }
    
    func resetUI() {
        //remove all previous gradient layers
        if let layers = gradientView.layer.sublayers {
            for layer in layers {
                if layer is CAGradientLayer {
                    layer.removeFromSuperlayer()
                }
            }
        }
        
        // Gradient view
        var gradient = CAGradientLayer()
        gradient.frame = gradientView.bounds
        gradient.colors = [UIColor.clearColor().CGColor, UIColor.blackColor().CGColor]
        
        gradientView.backgroundColor = .clearColor()
        gradientView.layer.insertSublayer(gradient, atIndex: 0)
        gradientView.alpha = 1
    }
    
}
