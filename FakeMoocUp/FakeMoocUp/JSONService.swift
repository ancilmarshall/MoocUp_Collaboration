
import UIKit

class JSONService {
    
    class func parse(data: NSData) -> [Course] {
        var error: NSError?
        let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error)
        
        if let dictionary = json as? [NSObject : AnyObject] {
            if let array = dictionary["elements"] as? [[NSObject : AnyObject]] {
                var coursesArray = [Course]()
                for dict in array {
                    if let name = dict["name"] as? String {
                        if let language = dict["language"] as? String {
                            let shortDescription = dict["shortDescription"] as? String
                            let recommendedBackground = dict["recommendedBackground"] as? String
                            coursesArray += [ Course(name: name, language: language, shortDescription: shortDescription, recommendedBackground: recommendedBackground)]
                        }
                    }
                }
                return coursesArray
            } else {
                println(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Error1"]))
            }
        } else {
            println(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Error1"]))
        }
        
        return []
    }
    
}
