//
//  Project.swift
//  TimeTrackerSwift
//
//  Created by Stefan Auvergne on 12/13/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import Foundation

class Project{
    var clientID:NSNumber?
    var creationDate:String
    var managerUserID:NSNumber
    var projectID:NSNumber
    var isInternalProject:Bool
    var isDisabled:Bool
    var description:String?
    var projectName:String
    var projectCategories = [ProjectCategory]()
    var projectModules = [ProjectModule]()

    init(dictionary:[String:Any]){
        self.clientID = dictionary["ClientiD"] as? NSNumber
        self.creationDate = dictionary["CreationDate"] as! String
        self.description = dictionary["Description"] as? String
        self.isDisabled = (dictionary["Disabled"] != nil)
        self.isInternalProject = (dictionary["InternalProject"] != nil)
        self.managerUserID = dictionary["ManagerUserID"] as! NSNumber
        self.projectName = dictionary["Name"] as! String
        self.projectID = dictionary["ProjectID"] as! NSNumber
        
        var tempArrayPC:[ProjectCategory] = []
        for dict in dictionary["ProjectCategories"] as! [AnyObject]{
            //create project category
            let categ = ProjectCategory.init(dictionary: dict as! [String : Any])
            
            //add to temp.append pass in each projects
            tempArrayPC.append(categ)
        }
        self.projectCategories = tempArrayPC
        tempArrayPC = []
        
        var tempArrayPM:[ProjectModule] = []
        for dict in dictionary["ProjectModules"] as! [AnyObject]{
            let categPM = ProjectModule.init(dictionary: dict as! [String : Any])
            tempArrayPM.append(categPM)
        }
        self.projectModules = tempArrayPM
        
        tempArrayPM = []
    }
}
