//
//  ProjectModule.swift
//  TimeTrackerSwift
//
//  Created by Stefan Auvergne on 12/13/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import Foundation

class ProjectModule{
    var moduleID:NSNumber
    var moduleName:String
    var projectID:NSNumber
    
    init(dictionary:[String:Any]){
        self.moduleID = dictionary["ModuleID"] as! NSNumber;
        self.moduleName = dictionary["ModuleName"] as! String;
        self.projectID = dictionary["ProjectID"] as! NSNumber;
    }
}
