//
//  ScrollView.swift
//  TimeTrackerSwift
//
//  Created by Stefan Auvergne on 1/23/17.
//  Copyright © 2017 com.example. All rights reserved.
//

import UIKit

class ScrollView: UIScrollView {
    
    var parent:CreateEntryViewController!
    var hitField:UITextField!
    var textFields:[UITextField]!
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if parent.projectTextField.frame.contains(point){
            if parent.blockSelectProject == true{
                parent.blockSelectProject = false
                return false
            }
            parent.selectProject(parent.projectTextField)
            return false
            
        }else if parent.categoryTextField.frame.contains(point){
            if parent.activeProject != nil{
                if parent.blockSelectCategory == true{
                    parent.blockSelectCategory = false
                    return false
                }
                parent.selectCategory(parent.categoryTextField)
                return false
            }
            return false
        }else if parent.dateTextField.frame.contains(point){
            parent.selectDate(parent.dateTextField)
            return false
        }else if parent.endTimeBtn.frame.contains(point){
            parent.endTime(parent.endTimeBtn)
            return false
        }else if parent.startTimeTextField.frame.contains(point){
            if parent.activeField == nil{
                parent.selectTime(parent.startTimeTextField)
                return false
            }
        }else if parent.endTimeTextField.frame.contains(point){
            if parent.activeField == nil{
                parent.selectTime(parent.endTimeTextField)
                return false
            }
        }else if parent.descriptionTextView.frame.contains(point){
            parent.descriptionTextView.becomeFirstResponder()
            return false
        }
        parent.dismissKeyboard()
        return true
    }
    
    func setParent(sender: CreateEntryViewController){
        parent = sender
    }
}
