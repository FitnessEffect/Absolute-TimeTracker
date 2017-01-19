//
//  Entry.swift
//  TimeTrackerSwift
//
//  Created by Stefan Auvergne on 12/12/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import Foundation

class Entry{
    
    var projectCategories = [ProjectCategory]()
    var projectModules = [ProjectModule]()
    
    var duration:Float
    
    var descript:String
    var projectName:String
    var category:String
    
    var entryID:NSNumber
    var categoryID:NSNumber
    var issueID:NSNumber
    var projectID:NSNumber
    var moduleID:NSNumber
    
    var creationDate:String
    var entryDate:String
    var startHour:String
    var endHour:String

    init(dictionary:[String:Any]){
        self.category = dictionary["CategoryName"] as! String
        self.duration = dictionary["Duration"] as! Float
        self.descript = dictionary["Description"] as! String
        self.projectName = dictionary["ProjectName"] as! String
        self.entryID = dictionary["EntryLogID"] as! NSNumber
        self.categoryID = dictionary["CategoryID"] as! NSNumber
        self.issueID = dictionary["IssueID"] as! NSNumber
        self.projectID = dictionary["ProjectID"] as! NSNumber
        self.moduleID = dictionary["ModuleID"] as! NSNumber
        self.creationDate = dictionary["CreationDate"] as! String
        self.entryDate = dictionary["EntryDate"] as! String
        self.startHour = dictionary["StartHour"] as! String
        self.endHour = dictionary["EndHour"] as! String
    }
}
