/**
  Networking.swift
  IOSMapperApp

  Created by Eben Du Toit on 2018/10/13.
  Copyright © 2018 Eben Du Toit. All rights reserved.
*/

import Foundation
import Alamofire
import SwiftyJSON

public struct Networking {
    /// type of url
    static let pretype = "http://"
    /// name of server
    static let dns = "ec2-18-191-152-232.us-east-2.compute.amazonaws.com"
    /// api endpoint for list
    static let globalZones = "/api/zones"
    /// api endpoint for details of zone
    static let innerZones = "/api/zones/"
    
    /* Get Zone list
 
     - Parameter completion: handle response (JSON)
    */
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
    
    
    /** Query detaled zone information
 
        - Parameters:
        - zoneId: Zone to query
        - completion: Handle response json
     */
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

}
