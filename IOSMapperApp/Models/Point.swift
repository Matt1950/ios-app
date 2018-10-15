/**
  Artwork.swift
  IOSMapperApp

  Created by Eben Du Toit on 2018/10/13.
  Copyright © 2018 Eben Du Toit. All rights reserved.
*/

import Foundation
import MapKit

class Point: NSObject, MKAnnotation {
    let title: String?
    var locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    /**
     Create Map annotation with custom attributes
    
     - Parameters:
       - title: Used Big text always visible
       - locationName: Subtitle
       - discipline: Specifies class of point
       - coordinate: Point on map
    */
    init(title: String,
         locationName: String,
         discipline: String,
         coordinate: CLLocationCoordinate2D) {
        
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}
