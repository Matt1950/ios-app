//
//  ModelFactory.swift
//  IOSMapperApp
//
//  Created by Eben Du Toit on 2018/10/14.
//  Copyright © 2018 Eben Du Toit. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct ModelFactory {

    static func createZone(subJson: JSON, parentZone: Zone?) -> Zone {

        let z = Zone(zoneJson: subJson, parentZone: parentZone)

        Networking.GetZoneInformation(zoneId: z.zoneID, completion: { (subZone) in

            let innerJsonResult = JSON(subZone ?? "[]")

            for (_, innerSubJson): (String, JSON) in innerJsonResult["innerZones"] {
                let innerZ = createZone(subJson: innerSubJson, parentZone: z)
                z.innerZones.append(innerZ)
            }

            for (_, innerSubJson): (String, JSON) in innerJsonResult["elements"] {
                let e = Element.init(elementJson: innerSubJson, zone: z)
                z.Elements.append(e)
            }

        })
        return z
    }
}
