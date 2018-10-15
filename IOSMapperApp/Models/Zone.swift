//
//  Zone.swift
//  IOSMapperApp
//
//  Created by Eben Du Toit on 2018/10/13.
//  Copyright © 2018 Eben Du Toit. All rights reserved.
//

import Foundation
import SwiftyJSON

class Zone: NSObject {
    let zoneID: String
    let zoneName: String
    let info: String
    let parentZone: Zone?
    var innerZones = [Zone]()
    var Elements = [Element]()
    
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

class Element: NSObject {
    let elementId: String
    let zoneID: String
    let zone: Zone?
    let elementType: Int
    let raw: String
    let classType: Int
    let geoJson: String
    let info: String
    
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
    
    
    init(elementId: String, zoneID: String, zone: Zone?, elementType: Int, raw: String, classType: Int, geoJson: String, info: String) {
        self.elementId = elementId
        self.zoneID = zoneID
        self.zone = zone
        self.elementType = elementType
        self.raw = raw
        self.classType = classType
        self.geoJson = geoJson
        self.info = info
    }
}

class LiveLocation: NSObject {
    let userID: String
    let pointRaw: String
    let geoJson: String
    
    init(userId: String, pointRaw: String, geoJson: String) {
        self.userID = userId
        self.pointRaw = pointRaw
        self.geoJson = geoJson
    }
}
