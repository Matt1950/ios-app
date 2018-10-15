//
//  Networking.swift
//  IOSMapperApp
//
//  Created by Eben Du Toit on 2018/10/13.
//  Copyright © 2018 Eben Du Toit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public struct Networking {
    static let pretype = "http://"
    static let dns = "ec2-18-191-152-232.us-east-2.compute.amazonaws.com"
    static let globalZones = "/api/zones"
    static let innerZones = "/api/zones/"
    
    
    // GET
    static func GetZones(completion: @escaping (JSON?) -> Void ) {
        let url :String = pretype + dns + globalZones
        Alamofire.request(url,method: .get)
            .validate()
            .responseJSON {
                response in
                guard response.result.isSuccess else {
                    print("Error while fetching remote rooms: (String(describing: response.result.error)")
                        completion(nil)
                    return
                }
               
                completion(JSON(response.result.value ?? "[]"))
        }
    }
    
    
    static func GetZoneInformation(zoneId: String, completion: @escaping (JSON?) -> Void ) {
        let url :String = pretype + dns + innerZones + zoneId
        
        Alamofire.request(url,method: .get)
            .validate()
            .responseJSON {
                response in
                guard response.result.isSuccess else {
                    print("Error while fetching remote rooms: (String(describing: response.result.error)")
                    completion(nil)
                    return
                }
                completion(JSON(response.result.value ?? "[]"))
        }
    }
//    static func GetInnerZones(zoneId: String, closure: @escaping (_ json: String)->()) {
//        Alamofire.request(pretype + dns + innerZones + zoneId).responseJSON { response in
//
//            case .success:
//                if let json = response.result.value {
//                    closure(json)
//                }
//            case .failure(_):
//                closure("")
//            }
//    }
   

}
