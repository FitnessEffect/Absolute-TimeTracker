//
//  PickerViewController.swift
//  TimeTrackerSwift
//
//  Created by Stefan Auvergne on 12/27/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate{
    
    var projectsPassed:[Project]!
    var categories:[ProjectCategory]!
    var currentProjectSelection:String!
    var currentCategorySelection:String!
    
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var pickerViewOutlet: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectBtn.layer.cornerRadius = 13.0
        selectBtn.clipsToBounds = true
        selectBtn.layer.borderWidth = 1
        selectBtn.layer.borderColor = UIColor.black.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setPickerValue()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setPickerValue(){
        var row = 0
        if currentProjectSelection != nil && currentProjectSelection != "" {
            for index in 0...projectsPassed.count-1{
                if projectsPassed[index].projectName == currentProjectSelection{
                    row = index
                }
            }
        }else{
            if currentCategorySelection != nil && currentCategorySelection != ""{
                for index in 0...categories.count-1{
                    if categories[index].categoryName == currentCategorySelection{
                        row = index
                    }
                }
                
            }
        }
        pickerViewOutlet.selectRow(row, inComponent: 0, animated: true)
    }
    
    func setProjects(array:[Project]){
        projectsPassed = array
    }
    
    func setCategoriesForProject(project:Project){
        categories = project.projectCategories
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if  projectsPassed == nil{
            return categories.count
        }else{
            return projectsPassed.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if projectsPassed == nil{
            return categories[row].categoryName
        }
        return projectsPassed[row].projectName
    }
    
    @IBAction func selectElement(_ sender: UIButton) {
        if projectsPassed == nil{
            let selectedValue = categories[pickerViewOutlet.selectedRow(inComponent: (0))]
            let presenter = self.presentingViewController as! CreateEntryViewController
            presenter.saveCategory(category: selectedValue)
        }else{
            let selectedValue = projectsPassed[pickerViewOutlet.selectedRow(inComponent: (0))]
            let presenter = self.presentingViewController as! CreateEntryViewController
            presenter.saveProject(project: selectedValue)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        var titleData:String!
        if projectsPassed == nil{
            titleData = categories[row].categoryName
        }else{
            titleData = projectsPassed[row].projectName
        }
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Gill Sans", size: 19.0)!,NSForegroundColorAttributeName:UIColor.black])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = NSTextAlignment.center
        
        return pickerLabel
    }
}
