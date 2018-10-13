//
//  CourseTableViewController.swift
//  IOSMapperApp
//
//  Created by Eben Du Toit on 2018/10/13.
//  Copyright © 2018 Eben Du Toit. All rights reserved.
//

import UIKit
import SwiftyJSON

class CourseTableViewController: UITableViewController, UISearchBarDelegate {

    var TableData: Array< JSON > = Array < JSON >()
    var VisibleData: Array< JSON > = Array < JSON >()
    var selected = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadCourses()
        self.clearsSelectionOnViewWillAppear = false
    }
    
    func searchBar(_: UISearchBar, textDidChange: String) {
        filterData(query: textDidChange)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VisibleData.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (!VisibleData[indexPath.row]["parentZoneID"].exists()){
            if (selected == VisibleData[indexPath.row]["zoneID"].stringValue) {
                selected = ""
            } else {
                selected = VisibleData[indexPath.row]["zoneID"].stringValue
            }
            refresh()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell

        cell.textLabel?.text = VisibleData[indexPath.row]["zoneName"].stringValue
        cell.detailTextLabel?.text = VisibleData[indexPath.row]["info"].stringValue
        cell.accessoryType = .disclosureIndicator
        if ( VisibleData[indexPath.row]["zoneID"].stringValue == selected ) {
            cell.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        } else {
            if (VisibleData[indexPath.row]["parentZoneID"].exists()){
                cell.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9137254902, alpha: 1)
            }else {
                cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            }
        }
        
        
        return cell
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - utils
    func refresh(){
        filterData()
        UIView.transition(with: tableView,
                                  duration: 0.45,
                                  options: .allowAnimatedContent,
                                  animations:
            { () -> Void in
                self.tableView.reloadData()
        },completion: nil);
        //self.refresher.endRefreshing()
        
    }

    func loadCourses() {
        Networking.GetZones { (result) in
            let jsonResult = JSON(result ?? "[]")
            for (_,subJson):(String, JSON) in jsonResult {
                Networking.GetInnerZones(zoneId: subJson, completion: { (subZone) in
                    self.TableData.append(subJson)
                    let innerJsonResult = JSON(subZone ?? "[]")
                    for (_,innerSubJson):(String, JSON) in innerJsonResult {
                        self.TableData.append(innerSubJson)
                    }
                    self.refresh()
                })
            }
            return
        }
    }
    
    func filterData() {
        var clone: Array< JSON > = Array < JSON >()
        
        for item in TableData {
            if (!item["parentZoneID"].exists()) {
                clone.append(item)
            }
            if (item["parentZoneID"].exists() && item["parentZoneID"].stringValue == selected) {
                clone.append(item)
            }
        }
        
        if (!clone.elementsEqual(VisibleData)){
            VisibleData.removeAll()
            VisibleData.append(contentsOf: clone)
        }
    }
    func filterData( query: String) {
        selected = "";
        var clone: Array< JSON > = Array < JSON >()
        if (query == ""){
            refresh()
            return
        }
        for item in TableData {
            if (!item["parentZoneID"].exists()) {
                if (item["zoneName"].stringValue.range(of: query, options: [.regularExpression, .caseInsensitive]) != nil) {
                        clone.append(item)
                }
                
            }
        }
        if (!clone.elementsEqual(VisibleData)){
            VisibleData.removeAll()
            VisibleData.append(contentsOf: clone)
        }
        
        UIView.transition(with: tableView,
                          duration: 0.45,
                          options: .allowAnimatedContent,
                          animations:
            { () -> Void in
                self.tableView.reloadData()
        },completion: nil);
    }
}
