//
//  FirstViewController.swift
//  IOSMapperApp
//
//  Created by Eben Du Toit on 2018/10/12.
//  Copyright © 2018 Eben Du Toit. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

class MapperViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    //let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    let regionRadius: CLLocationDistance = 1000
    var prevZone: Zone? = nil
    var holeOverlays:Array<PolygonInformation> = Array<PolygonInformation>()
   
    // location
    var locationManager: CLLocationManager!
    var seenError : Bool = false
    var locationFixAchieved : Bool = false
    var locationStatus : NSString = "Not Started"

    
    
    
    func centerMapOnLocation() {
        if ( holeOverlays.count == 0 ){
            if let first = self.mapView.overlays.first {
                let rect = self.mapView.overlays.reduce(first.boundingMapRect, {$0.union($1.boundingMapRect)})
                self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), animated: true)
            }
        } else {
            if let first = holeOverlays.first {
                let rect = holeOverlays.reduce(first.boundingMapRect, {$0.union($1.boundingMapRect)})
                self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self;
        locationManager = CLLocationManager()
        determineMyCurrentLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let barViewControllers = self.tabBarController?.viewControllers
        let courses = barViewControllers![0] as! CourseTableViewController
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        for element in courses.selectedOuter?.Elements ?? [] {
            switch element.elementType {
            case 1:
                let geoJson = JSON.init(parseJSON: element.geoJson)
                let artwork = Point(title: element.info,
                                    locationName: "Element class",
                                    discipline: element.elementId,
                                    coordinate: CLLocationCoordinate2D(latitude: geoJson["coordinates"].array?[1].doubleValue ?? 21.282778,
                                                                       longitude: geoJson["coordinates"].array?[0].doubleValue ?? -157.829444))
                mapView.addAnnotation(artwork)
                break;
            case 0:
                let geoJson = JSON.init(parseJSON: element.geoJson)
                let jsonCoords = geoJson["coordinates"][0]
                var coords: Array< CLLocationCoordinate2D > = Array < CLLocationCoordinate2D >()
                for (_, pair) in jsonCoords {
                    let pairJson = JSON(pair)
                    coords.append(CLLocationCoordinate2D(latitude: pairJson[1].doubleValue ,
                                                         longitude: pairJson[0].doubleValue))
                }
                let polygon = PolygonInformation(coordinates: coords, count: coords.count)
                polygon.classType = element.classType
                mapView?.addOverlay(polygon)
                
                break;
            default:
                break;
            }
            
        }
        holeOverlays.removeAll()
        for element in courses.selectedInner?.Elements ?? [] {
            switch element.elementType {
            case 1:
                let coords = JSON.init(parseJSON: element.geoJson)
                let artwork = Point(title: element.info,
                                    locationName: "Hole class",
                                    discipline: element.elementId,
                                    coordinate: CLLocationCoordinate2D(latitude: coords["coordinates"].array?[1].doubleValue ?? 21.282778,
                                                                       longitude: coords["coordinates"].array?[0].doubleValue ?? -157.829444))
                mapView.addAnnotation(artwork)
                break;
            case 0:
                let geoJson = JSON.init(parseJSON: element.geoJson)
                let jsonCoords = geoJson["coordinates"][0]
                var coords: Array< CLLocationCoordinate2D > = Array < CLLocationCoordinate2D >()
                for (_, pair) in jsonCoords {
                    let pairJson = JSON(pair)
                    coords.append(CLLocationCoordinate2D(latitude: pairJson[1].doubleValue ,
                                                         longitude: pairJson[0].doubleValue))
                }
                let polygon = PolygonInformation(coordinates: coords, count: coords.count)
                polygon.classType = element.classType
                mapView?.addOverlay(polygon)
                holeOverlays.append(polygon)
            default:
                break;
            }
        }
        if (prevZone != courses) {
            prevZone = courses.selectedOuter
            centerMapOnLocation()
        }
        
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
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is PolygonInformation {
            let renderer = MKPolygonRenderer(polygon: overlay as! PolygonInformation)
            switch (overlay as! PolygonInformation).classType {
            case 0 :
                renderer.fillColor = #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1).withAlphaComponent(0.3)
                renderer.strokeColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
                renderer.lineWidth = 0.5
                return renderer
            case 1 :
                renderer.fillColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1).withAlphaComponent(0.5)
                renderer.strokeColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                renderer.lineWidth = 0.5
                return renderer
            case 2 :
                renderer.fillColor = #colorLiteral(red: 0.7742854953, green: 0.8705892563, blue: 0.4055302739, alpha: 1).withAlphaComponent(0.5)
                renderer.strokeColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
                renderer.lineWidth = 0.5
                return renderer
            case 3 :
                renderer.fillColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1).withAlphaComponent(0.5)
                renderer.strokeColor = #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1)
                renderer.lineWidth = 0.5
                return renderer
            case 4 :
                renderer.fillColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1).withAlphaComponent(0.5)
                renderer.strokeColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
                renderer.lineWidth = 0.5
                return renderer
            default :
                renderer.fillColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1).withAlphaComponent(0.5)
                renderer.strokeColor = #colorLiteral(red: 0.1333333333, green: 0.1568627451, blue: 0.1921568627, alpha: 1)
                renderer.lineWidth = 0.5
                return renderer
            }
        }
        
        return MKOverlayRenderer()
    }
    
    func determineMyCurrentLocation() {
        // 1
        let status  = CLLocationManager.authorizationStatus()
        
        // 2
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        // 3
        if status == .denied || status == .restricted {
            let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
            return
        }
        
        // 4
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
}
