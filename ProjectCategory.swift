//
//  ProjectCategory.swift
//  TimeTrackerSwift
//
//  Created by Stefan Auvergne on 12/13/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import Foundation

class ProjectCategory{
    
    var abbreviation:String
    var categoryID:NSNumber
    var categoryName:String
    var projectID:NSNumber
    
    init(dictionary:[String:Any]){
        self.abbreviation = dictionary["Abbreviation"] as! String;
        self.categoryID = dictionary["CategoryID"] as! NSNumber;
        self.categoryName = dictionary["Name"] as! String;
        self.projectID = dictionary["ProjectID"] as! NSNumber;
    }
}
