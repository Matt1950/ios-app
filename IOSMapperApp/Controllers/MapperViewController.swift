//
//  FirstViewController.swift
//  IOSMapperApp
//
//  Created by Eben Du Toit on 2018/10/12.
//  Copyright © 2018 Eben Du Toit. All rights reserved.
//

import UIKit
import MapKit

class MapperViewController: UIViewController, MKMapViewDelegate {

        
    @IBOutlet weak var mapView: MKMapView!
    let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        centerMapOnLocation(location: initialLocation)
        let artwork = Point(title: "King David Kalakaua",
                              locationName: "Waikiki Gateway Park",
                              discipline: "Sculpture",
                              coordinate: CLLocationCoordinate2D(latitude: 21.283921, longitude: -157.831661))
        mapView.addAnnotation(artwork)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 2
        guard let annotation = annotation as? Point else { return nil }
        // 3xw
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
}
