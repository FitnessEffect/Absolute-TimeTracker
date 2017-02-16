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
    
    @IBOutlet weak var pickerViewOutlet: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(PickerViewController.pickerTapped))
        self.pickerViewOutlet.addGestureRecognizer(tap)
        tap.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pickerTapped(){
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
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
//    {
//        if projectsPassed == nil{
//            let selectedValue = categories[pickerViewOutlet.selectedRow(inComponent: (0))]
//            
//            let presenter = self.presentingViewController as! CreateEntryViewController
//            presenter.saveCategory(category: selectedValue)
//        }else{
//            let selectedValue = projectsPassed[pickerViewOutlet.selectedRow(inComponent: (0))]
//            
//            let presenter = self.presentingViewController as! CreateEntryViewController
//            presenter.saveProject(project: selectedValue)
//        }
//    }
    
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
