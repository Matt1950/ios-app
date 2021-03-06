/**
 - Author   : Eben du toit
 - File : MapperViewController.swift
 - Class    : MapperViewController
 
 ### Mapper view controller implements
 1. UIViewController
 2. MKMapViewDelegate
 3. CLLocationManagerDelegate
 */

import UIKit
import MapKit
import SwiftyJSON


extension Double {
    func roundToPlaces(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

class MapperViewController:
        UIViewController,
        MKMapViewDelegate,
        CLLocationManagerDelegate {
    // MARK: - Member Variables
    /// Map view used
    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 1000
    var prevZone: Zone? = nil
    var holeOverlays:Array<PolygonInformation> = Array<PolygonInformation>()
    var locationManager: CLLocationManager!
    var seenError : Bool = false
    var locationFixAchieved : Bool = false
    var locationStatus : NSString = "Not Started"
    var currentSelectedHoleTee : CLLocationCoordinate2D? = nil
    var userLocation :CLLocationCoordinate2D? = nil
    let defaultLat : Double = 21.282778
    let defaultLng : Double = -157.829444
    let elements: [String] = ["Point of interest", "Hole", "Tee"]
    let elementsPoly: [String] = ["Rough", "Fairway", "Green",
                                  "Bunker", "Water"]
    
    @IBOutlet weak var informationLale: UILabel!
    @IBOutlet weak var distanceLable: UILabel!
    
    // MARK: - UIViewController Delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self;
        locationManager = CLLocationManager()
        determineCurrentLocation()
    }
    
    /**
     viewDidAppear(_ animated: Bool) : nil
     
     Populate the map with polygons and points based on the parent's structure
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let barViewControllers = self.tabBarController?.viewControllers
        let courses = barViewControllers![0] as! CourseTableViewController
        var innerZoneName = ""
        if (courses.selectedInner != nil){
            innerZoneName = " - " + (courses.selectedInner?.zoneName ?? "")
        } else {
            innerZoneName = courses.selectedInner?.zoneName ?? ""
        }
        self.informationLale.text = ((courses.selectedOuter?.zoneName ?? "") +
             innerZoneName )
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        for element in courses.selectedOuter?.Elements ?? [] {
            switch element.elementType {
            case 1:
                let geoJson = JSON.init(parseJSON: element.geoJson)
                
                let pinLoc = CLLocationCoordinate2D(
                    latitude: geoJson["coordinates"].array?[1].doubleValue
                        ?? defaultLat,
                    longitude: geoJson["coordinates"].array?[0].doubleValue
                        ?? defaultLng
                )
                let point = Point(title: elements[element.classType],
                                  locationName: "",
                                  discipline: element.info,
                                  coordinate: pinLoc
                )
                mapView.addAnnotation(point)
                break;
            case 0:
                let geoJson = JSON.init(parseJSON: element.geoJson)
                let jsonCoords = geoJson["coordinates"][0]
                var coords: Array<CLLocationCoordinate2D>
                    = Array <CLLocationCoordinate2D> ()
                
                for (_, pair) in jsonCoords {
                    let pairJson = JSON(pair)
                    coords.append(
                        CLLocationCoordinate2D(
                            latitude: pairJson[1].doubleValue,
                            longitude: pairJson[0].doubleValue
                        )
                    )
                }
                let polygon = PolygonInformation(coordinates: coords,
                                                 count: coords.count)
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
                let pinLoc = CLLocationCoordinate2D(
                    latitude: coords["coordinates"].array?[1].doubleValue
                        ?? defaultLat,
                    longitude: coords["coordinates"].array?[0].doubleValue
                        ?? defaultLng
                )
                if (element.classType == 1) {
                    currentSelectedHoleTee = CLLocationCoordinate2D.init (
                        latitude: pinLoc.latitude,
                        longitude: pinLoc.longitude
                    )
                    if ( userLocation != nil) {
                        let distance = CLLocation.init(
                            latitude: userLocation!.latitude,
                            longitude: userLocation!.longitude
                        ).distance (from: CLLocation.init (
                            latitude: pinLoc.latitude,
                            longitude: pinLoc.longitude
                            )
                        )
                        self.distanceLable.text = "⛳️ " + String (
                            format:"%.2f", distance) + recommendClub(
                                dist: distance
                        )
                    }
                }
                
                let point = Point(title: elements[element.classType],
                                    locationName: "",
                                    discipline: element.info,
                                    coordinate: pinLoc
                                )
                mapView.addAnnotation(point)
                break;
            case 0:
                let geoJson = JSON.init(parseJSON: element.geoJson)
                let jsonCoords = geoJson["coordinates"][0]
                var coords: Array<CLLocationCoordinate2D>
                        = Array <CLLocationCoordinate2D> ()
                
                for (_, pair) in jsonCoords {
                    let pairJson = JSON(pair)
                    coords.append(CLLocationCoordinate2D (
                            latitude: pairJson[1].doubleValue,
                            longitude: pairJson[0].doubleValue
                        )
                    )
                }
                let polygon = PolygonInformation(
                    coordinates: coords,
                    count: coords.count
                )
                
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
    // MARK: - MapKit Delegates
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? Point else { return nil }
        let identifier = "marker"
        
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView
                .dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            if (userLocation != nil){
                dequeuedView.animatesWhenAdded = true;
                
                let distance = CLLocation.init(
                    latitude: userLocation!.latitude,
                    longitude: userLocation!.longitude
                    ).distance (from: CLLocation.init (
                        latitude: annotation.coordinate.latitude,
                        longitude: annotation.coordinate.longitude
                    )
                )
                annotation.locationName = "⛳️ " + String (
                    format:"%.2f", distance) + recommendClub(
                        dist: distance
                )
            }
            
            dequeuedView.annotation = annotation
            if (annotation.title == elements[1]){
                dequeuedView.glyphImage = #imageLiteral(resourceName: "flag")
            } else if (annotation.title == elements[2]){
                dequeuedView.glyphImage = #imageLiteral(resourceName: "tee")
            }
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation,
                                          reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    
    func mapView(_ mapView: MKMapView,
                 rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is PolygonInformation {
            let renderer = MKPolygonRenderer(
                polygon: overlay as! PolygonInformation)
            switch (overlay as! PolygonInformation).classType {
            case 0 :
                renderer.fillColor = UIColor(red: 0.1294117719,
                                             green: 0.2156862766,
                                             blue: 0.06666667014,
                                             alpha: 1).withAlphaComponent(0.3)
                renderer.strokeColor = UIColor(red: 0.721568644,
                                               green: 0.8862745166,
                                               blue: 0.5921568871, alpha: 1)
                renderer.lineWidth = 0.5
                return renderer
            case 1 :
                renderer.fillColor = UIColor(red: 0.2745098174,
                                             green: 0.4862745106,
                                             blue: 0.1411764771,
                                             alpha: 1).withAlphaComponent(0.5)
                renderer.strokeColor = UIColor(red: 0.4666666687,
                                               green: 0.7647058964,
                                               blue: 0.2666666806, alpha: 1)
                renderer.lineWidth = 0.7
                return renderer
            case 2 :
                renderer.fillColor = UIColor(red: 0.7742854953,
                                             green: 0.8705892563,
                                             blue: 0.4055302739,
                                             alpha: 1).withAlphaComponent(0.5)
                renderer.strokeColor = UIColor(red: 0.5568627715,
                                               green: 0.3529411852,
                                               blue: 0.9686274529, alpha: 1)
                renderer.lineWidth = 0.7
                return renderer
            case 3 :
                renderer.fillColor = UIColor(red: 0.9529411793,
                                             green: 0.6862745285,
                                             blue: 0.1333333403,
                                             alpha: 1).withAlphaComponent(0.5)
                renderer.strokeColor = UIColor(red: 0.3098039329,
                                               green: 0.2039215714,
                                               blue: 0.03921568766, alpha: 1)
                renderer.lineWidth = 0.7
                return renderer
            case 4 :
                renderer.fillColor = UIColor(red: 0.2392156869,
                                             green: 0.6745098233,
                                             blue: 0.9686274529,
                                             alpha: 1).withAlphaComponent(0.7)
                renderer.strokeColor = UIColor(red: 0.1215686277,
                                               green: 0.01176470611,
                                               blue: 0.4235294163, alpha: 1)
                renderer.lineWidth = 0.7
                return renderer
            default :
                renderer.fillColor = UIColor(red: 0.3333333433,
                                             green: 0.3333333433,
                                             blue: 0.3333333433,
                                             alpha: 1).withAlphaComponent(0.5)
                renderer.strokeColor = UIColor(red: 0.1333333333,
                                               green: 0.1568627451,
                                               blue: 0.1921568627, alpha: 1)
                renderer.lineWidth = 0.7
                return renderer
            }
        }
        
        return MKOverlayRenderer()
    }
    
    
    // MARK: - Location Manager Delegates
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        userLocation =  CLLocationCoordinate2D.init(
            latitude: locations[0].coordinate.latitude,
            longitude: locations[0].coordinate.longitude
        )
        
        if ( currentSelectedHoleTee != nil && userLocation != nil) {
            let distance = CLLocation.init(
                latitude: userLocation!.latitude,
                longitude: userLocation!.longitude
                ).distance (
                    from: CLLocation.init (
                        latitude: currentSelectedHoleTee!.latitude,
                        longitude: currentSelectedHoleTee!.longitude
                    )
            )
            self.distanceLable.text = "⛳️ " + String (
                format:"%.2f", distance) + recommendClub(
                    dist: distance
            )
        }
        
        let location: JSON = [
            "type": "Point",
            "coordinates": [
                Double(userLocation!.longitude
                    ).roundToPlaces(places: 6),
                
                Double(userLocation!.latitude
                    ).roundToPlaces(places: 6)
            ]
        ]
        
        Networking.sendMessage(message: location.rawString(),
                               defaults: (self.tabBarController as!
                                ParentViewController).defaults
        )
    }
    
    // MARK: - Custom Functionality
    
    
    /**
     Postconditions:
     Calculates the best position for the map to center on
     1. If the map has a OuterZone selected : The OuterZone with padding
     2. If the map has a InnerZone selected : The InnerZone with padding
     3. If nothing selected : the user location
     */
    func centerMapOnLocation() {
        
        if ( holeOverlays.count == 0 ){
            if let first = self.mapView.overlays.first {
                let rect = self.mapView.overlays.reduce(
                    first.boundingMapRect, {$0.union($1.boundingMapRect)})
                self.mapView.setVisibleMapRect(
                    rect,
                    edgePadding:UIEdgeInsets(top: 50.0,
                                             left: 50.0,
                                             bottom: 50.0,
                                             right: 50.0
                    )
                    ,animated: true
                )
            }
        } else {
            if let first = holeOverlays.first {
                let rect = holeOverlays.reduce(first.boundingMapRect,
                                               {$0.union($1.boundingMapRect)})
                self.mapView.setVisibleMapRect(
                    rect,
                    edgePadding:UIEdgeInsets(
                        top: 50.0,
                        left: 50.0,
                        bottom: 50.0,
                        right: 50.0
                    ),
                    animated: true)
            }
        }
    }
    

    /// Detremine if the application has access to location services
    func determineCurrentLocation() {
        let status  = CLLocationManager.authorizationStatus()
        
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if status == .denied || status == .restricted {
            let alert = UIAlertController(
                title: "Location Services Disabled",
                message: "Please enable Location Services in Settings",
                preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK",
                                         style: .default,
                                         handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
            return
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    /***
     * recommendClub(double) : String
     *
     *     Takes the distance from the player to the current hole as a
     *     parameter. Returns the name of the recommended club based on
     *     average club ranges.
     ***/
    func recommendClub(dist : Double) -> String {
        let clubs = [ "Driver", "3-wood", "2-iron", "3-iron",
                      "4-iron", "5-iron", "6-iron", "7-iron",
                      "8-iron", "9-iron", "Pitching wedge",
                      "Sand wedge", "Lob wedge" ]
    
        let distances:[Double] = [200,180,165,155,146,
                                  137,128,119,110,101,
                                  91,78,55]
    
        var smallest: Double = abs(dist - distances[0])
        var smallestIndex: Int = 0
        for i in 1...distances.count - 1 {
            let diff: Double = abs(dist - distances[i])
            if (diff < smallest) {
                smallest = diff
                smallestIndex = i
            }
        }
        return " 🏌🏼‍♂️ " + clubs[smallestIndex]
    }

}
