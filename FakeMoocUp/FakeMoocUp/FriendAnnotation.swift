
import MapKit

class FriendAnnotation: NSObject, MKAnnotation {
    
    let title: String
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    var subtitle: String { return locationName }
    
    
    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        
        super.init()
    }

}
