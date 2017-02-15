//
//  StoryboardSegue.swift
//  TimeTrackerSwift
//
//  Created by Stefan Auvergne on 2/14/17.
//  Copyright © 2017 com.example. All rights reserved.
//

import Foundation
import UIKit

class StoryboardSegue: UIStoryboardSegue{
    
    override init(identifier:String?, source:UIViewController, destination:UIViewController){
        super.init(identifier: identifier, source: source, destination: destination as! CalendarViewController)
    }
}
