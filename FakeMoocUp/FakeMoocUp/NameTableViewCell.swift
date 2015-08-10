
import UIKit

class NameTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .None
       label.numberOfLines = 0
        label.font = UIFont.boldSystemFontOfSize(CGFloat(17))
    }

}
