//
//  EmergencyLocation.swift
//  HelpMe
//
//  Created by Aditya  Bhandari on 5/22/16.
//  Copyright © 2016 Aditya  Bhandari. All rights reserved.
//

import UIKit
import MapKit

class EmergencyLocation: UIViewController, MKMapViewDelegate  {
    
    @IBOutlet var map: MKMapView!
    
    var dict = [AnyHashable: Any]  ()
    
    var location:CLLocation?
    
    let regionRadius: CLLocationDistance = 1000
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
  NotificationCenter.default.addObserver(self, selector: #selector(EmergencyLocation.onEmergencyOccurence(_:)) , name: NSNotification.Name(rawValue: "onMessageRecieved"), object: nil)
        
        self.title = "\(dict["userName"] as! String) is in Emergency"
        
        map.delegate = self
        
        DisplayLocationOnMap(dict)
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(nil, forKey: "remoteNotification")
        userDefaults.set(nil, forKey: "isRemoteNotificationAvailible")

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func onEmergencyOccurence (_ notification: Notification) {
        
            
        }
    
    func DisplayLocationOnMap(_ dict: [AnyHashable: Any]) {

        let latitude:CLLocationDegrees = Double(dict["latitude"] as! String)!
        let longitude:CLLocationDegrees = Double(dict["longitude"] as! String)!
        
        let loc:CLLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        location = loc
        
        
        let regionCoordinate = MKCoordinateRegionMakeWithDistance(loc.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        
        map.setRegion(regionCoordinate, animated: true)
        
        map.removeAnnotations(map.annotations)
        
        let artwork = Pin.init(title: "\(dict["userName"] as! String)'s Location", locationName: "", discipline: "", coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        map.addAnnotation(artwork)
        
        
    }
 
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? Pin{
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = map.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else{
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                let button = UIButton(type: .detailDisclosure)
                view.rightCalloutAccessoryView = button
            }
            return view
        }
        return nil
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)  {
        
        let location = view.annotation as! Pin
        let launchOption = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOption)
        
    }
    
}





