
import UIKit

class TextViewTableViewCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .None
        textView.font = UIFont.systemFontOfSize(14.0) // TODO: font may vary
        textView.scrollEnabled = false
        textView.userInteractionEnabled = true
        textView.selectable = true
        textView.editable = false
    }

}
