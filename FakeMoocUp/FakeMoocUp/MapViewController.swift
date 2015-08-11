
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    let locationManager = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self

        // Add pin gesture
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "handleLongPressGesture:")
        longPressGesture.minimumPressDuration = 0.6 // 1
        mapView.addGestureRecognizer(longPressGesture)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setUserLocation()
    }
    
    func setUserLocation() {
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView.setUserTrackingMode(.Follow, animated: true)
        }
    }
    
    func handleLongPressGesture(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let coordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            
            /*
            // MKPointAnnotation (no need for MKMapViewDelegate)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "New pin"
            mapView.addAnnotation(annotation)
            */
            
            // ContactAnnotation (subclass of MKAnnotation)
            let annotation = ContactAnnotation(title: "New pin", locationName: "Bô kay manman'w", coordinate: coordinate)
            mapView.addAnnotation(annotation)
        }
    }
    
    // MARK: - MKMapViewDelegate
    // Add accessoryView to comments
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = annotation as? ContactAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true // default: false
                
                //
                view.draggable = true
                view.canShowCallout = true
                view.animatesDrop = true
                //

                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView // UIButtonType
            }
            
            return view
        }
        return nil
    }

}
