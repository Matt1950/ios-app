/**
  PolygonInformation.swift
  IOSMapperApp

  Created by Eben Du Toit on 2018/10/14.
  Copyright © 2018 Eben Du Toit. All rights reserved.
*/

import UIKit
import MapKit

/// Custom polygon used to draw on map
class PolygonInformation: MKPolygon {
    /// Added class type to specify styling based on api
    var classType: Int = 0
}
