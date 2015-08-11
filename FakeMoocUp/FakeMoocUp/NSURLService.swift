
import Foundation

class NSURLService {
    
    typealias completionClosure = (data: NSData?, error: NSError?) -> Void
    
    
    class func loadDataFromURL(url: NSURL, completion: completionClosure?) {
        let session = NSURLSession.sharedSession()
        
        let loadDataTask = session.dataTaskWithURL(url) { data, response, error -> Void in
            if let error = error {
                completion?(data: nil, error: error)
            } else {
                let httpResponse = response as! NSHTTPURLResponse // NSURLResponse from NSURLSession are always NSHTTPURLResponse
                if httpResponse.statusCode != 200 {
                    let statusError = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                    completion?(data: nil, error: statusError)
                } else {
                    if let data = data {
                        completion?(data: data, error: nil)
                    } else {
                        let statusError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "HTTP object is null."])
                        completion?(data: nil, error: statusError)
                    }
                }
            }
        }
        
        loadDataTask.resume()
    }
    
}
