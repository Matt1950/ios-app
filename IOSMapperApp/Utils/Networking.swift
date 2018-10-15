/**
  Networking.swift
  IOSMapperApp

  Created by Eben Du Toit on 2018/10/13.
  Copyright © 2018 Eben Du Toit. All rights reserved.
*/

import Foundation
import Alamofire
import Starscream
import SwiftyJSON

public struct Networking {
    static var socket: WebSocket? = nil
    /// Url type for api get requests
    static let apiType = "http://"
    /// Url Type for websocket
    static let webSocketType = "ws://"
    /// name of server
    static let dns = "ec2-18-191-152-232.us-east-2.compute.amazonaws.com"
    /// api endpoint for list
    static let globalZones = "/api/zones"
    /// api endpoint for details of zone
    static let innerZones = "/api/zones/"
    /// Endpoint for websocket
    static let webSocketEndpoint = "/ws"
    
    /* Get Zone list
 
     - Parameter completion: handle response (JSON)
    */
    static func GetZones(completion: @escaping (JSON?) -> Void ) {
        let url :String = apiType + dns + globalZones
        Alamofire.request(url,method: .get)
            .validate()
            .responseJSON {
                response in
                guard response.result.isSuccess else {
                        completion(nil)
                    return
                }
               
                completion(JSON(response.result.value ?? "[]"))
        }
    }
    
    
    /** Query detailed zone information
 
        - Parameters:
        - zoneId: Zone to query
        - completion: Handle response json
     */
    static func GetZoneInformation(zoneId: String,
                                   completion: @escaping (JSON?) -> Void ) {
        let url :String = apiType + dns + innerZones + zoneId
        
        Alamofire.request(url,method: .get)
            .validate()
            .responseJSON {
                response in
                guard response.result.isSuccess else {
                    completion(nil)
                    return
                }
                completion(JSON(response.result.value ?? "[]"))
        }
    }
    
    static func connectToWebsocket(message: String?, userID: String?) {
        let url = webSocketType + dns + webSocketEndpoint
        if (socket == nil) {
            socket = WebSocket(url: URL(string: url)!)
            //websocketDidConnect
            socket!.onConnect = {
                if (message != nil){
                    socket?.write(string: message!)
                }
            }
            //websocketDidDisconnect
            socket!.onDisconnect = { (error: Error?) in
                socket = nil;
            }
            //websocketDidReceiveMessage
            socket!.onText = { (text: String) in
                let jsonString = JSON.init(parseJSON: text)
                if (userID == nil) {
                        UserDefaults.standard.set (
                            jsonString["UserID"].stringValue,
                            forKey:"UserID")
                }
            }
            socket!.connect()
        } else {
            if (message != nil){
                socket?.write(string: message!)
            }
        }
    }
    
    static func sendMessage(message: String?, defaults: UserDefaults?) {
        if (message != nil) {
            if (defaults?.string(forKey: "UserID") == nil) {
                let locationMessage: JSON = [
                    "Location": message!,
                    ]
                connectToWebsocket(message: locationMessage.rawString(),
                                   userID: defaults?.string(forKey: "UserID"))
            } else {
                let locationMessage: JSON = [
                    "UserID": defaults?.string(forKey: "UserID") ?? "",
                    "Location": message!,
                    ]
                connectToWebsocket(message: locationMessage.rawString(),
                                   userID: defaults?.string(forKey: "UserID"))
            }
            
            if socket?.isConnected ?? false {
                let locationMessage: JSON = [
                    "UserID": defaults?.string(forKey: "UserID") ?? "",
                    "Location": message!,
                    ]
                socket?.write(string: locationMessage.rawString() ?? "")
            }
        }
    }
}
