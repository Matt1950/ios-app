/**
  Zone.swift
  IOSMapperApp

  Created by Eben Du Toit on 2018/10/13.
  Copyright © 2018 Eben Du Toit. All rights reserved.
*/

import Foundation
import SwiftyJSON

class Zone: NSObject {
    let zoneID: String
    let zoneName: String
    let info: String
    let parentZone: Zone?
    var innerZones = [Zone]()
    var Elements = [Element]()
    /**
     Instantiate zone from json
    
     - Parameters:
       - zoneJson: Zone json from api
       - parentZone: nullable parent zone
    */
    init(zoneJson: JSON, parentZone: Zone?) {
        self.zoneID = zoneJson["zoneID"].stringValue
        self.zoneName = zoneJson["zoneName"].stringValue
        self.info = zoneJson["info"].stringValue
        self.parentZone = parentZone
    }
    
    init(zoneID: String, zoneName: String, info: String, parentZone: Zone?) {
        self.zoneID = zoneID
        self.zoneName = zoneName
        self.info = info
        self.parentZone = parentZone
    }
    
}

/// construct for elements
class Element: NSObject {
    let elementId: String
    let zoneID: String
    let zone: Zone?
    let elementType: Int
    let raw: String
    let classType: Int
    let geoJson: String
    let info: String
    /**
     Instantiate element from json
    
     - Parameters:
       - elementJson: Json from server
       - zone: Zone in wich element exists
    */
    init(elementJson: JSON, zone: Zone?){
        self.elementId = elementJson["elementId"].stringValue
        self.zoneID = elementJson["zoneID"].stringValue
        self.zone = zone
        self.elementType = elementJson["elementType"].intValue
        self.raw = elementJson["raw"].stringValue
        self.classType = elementJson["classType"].intValue
        self.geoJson = elementJson["geoJson"].stringValue
        self.info = elementJson["info"].stringValue
    }
    
}

class LiveLocation: NSObject {
    let userID: String
    let pointRaw: String
    let geoJson: String
    /**
     Live location used for web socket
    
     - Parameters:
       - userId: User id provided by server, can be sent as
     random if privacy == concern
       - pointRaw: Current location of user as WKB
       - geoJson: Current location of user as geoJSON
    */
    init(userId: String, pointRaw: String, geoJson: String) {
        self.userID = userId
        self.pointRaw = pointRaw
        self.geoJson = geoJson
    }
}
