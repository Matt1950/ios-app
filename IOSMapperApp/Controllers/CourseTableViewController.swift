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

    var TableData: Array< Zone > = Array < Zone >()
    var VisibleData: Array< Zone > = Array < Zone >()
    var selectedOuter :Zone?
    var selectedInner :Zone?
    
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VisibleData.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (VisibleData[indexPath.row].parentZone == nil){
            if (selectedOuter == VisibleData[indexPath.row]) {
                selectedOuter = nil
            } else {
                selectedOuter = VisibleData[indexPath.row]
            }
            refresh()
        } else {
            if (selectedInner == VisibleData[indexPath.row]) {
                selectedOuter = selectedInner?.parentZone
                selectedInner = nil
                let cell = tableView.cellForRow(at: indexPath)
                cell?.setSelected(false, animated: true)
            } else {
                selectedInner = VisibleData[indexPath.row]
                selectedOuter = selectedInner?.parentZone
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell

        cell.textLabel?.text = VisibleData[indexPath.row].zoneName
        cell.detailTextLabel?.text = VisibleData[indexPath.row].info
        cell.accessoryType = .none
        if ( VisibleData[indexPath.row] == selectedOuter ) {
            cell.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        } else {
            if (VisibleData[indexPath.row].parentZone != nil){
                cell.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9137254902, alpha: 1)
                cell.accessoryType = .disclosureIndicator
            }else {
                cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            }
        }
        return cell
    }
    
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
    }

    func loadCourses() {
        Networking.GetZones { (result) in
            let jsonResult = JSON(result ?? "[]")
            for (_,subJson):(String, JSON) in jsonResult {
                    let z = ModelFactory.createZone(subJson: subJson, parentZone: nil)
                    self.TableData.append(z)
                    self.refresh()
            }
            return
        }
    }
    
    func filterData() {
        var clone: Array< Zone > = Array < Zone >()
        for item in TableData {
            if (item.parentZone == nil) {
                clone.append(item)
                if ( item == selectedOuter) {
                    clone.append(contentsOf: item.innerZones)
                }
            }
        }
        
        if (!clone.elementsEqual(VisibleData)){
            VisibleData.removeAll()
            VisibleData.append(contentsOf: clone)
        }
    }
    
    func filterData( query: String) {
        var clone: Array< Zone > = Array < Zone >()
        if (query == ""){
            refresh()
            return
        }
        
        for item in TableData {
            if (item.parentZone == nil) {
                if (item.zoneName.range(of: query, options: [.regularExpression, .caseInsensitive]) != nil) {
                        clone.append(item)
                }
                
            }
        }
        
        if (!clone.elementsEqual(VisibleData)){
            VisibleData.removeAll()
            selectedOuter = nil;
            selectedInner = nil;
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
