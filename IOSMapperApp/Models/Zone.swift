//
//  Zone.swift
//  IOSMapperApp
//
//  Created by Eben Du Toit on 2018/10/13.
//  Copyright © 2018 Eben Du Toit. All rights reserved.
//

import Foundation

class Zone: NSObject {
    let zoneID: String
    let zoneName: String
    let info: String
    let parentZone: Zone?

    init(zoneID: String, zoneName: String, discipline: String, info: String, parentZone: Zone?) {
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
    let elementType: String
    let raw: String
    let classType: String
    let geoJson: String
    let info: String
    init(elementId: String, zoneID: String, zone: Zone?, elementType: String, raw: String, classType: String, geoJson: String, info: String) {
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
