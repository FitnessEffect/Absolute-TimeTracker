//
//  PickerViewController.swift
//  TimeTrackerSwift
//
//  Created by Stefan Auvergne on 12/27/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var projectsPassed:[Project]!
    var categories:[ProjectCategory]!
    
    @IBOutlet weak var pickerViewOutlet: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if projectsPassed == nil{
        let selectedValue = categories[pickerViewOutlet.selectedRow(inComponent: (0))]
        
        let presenter = self.presentingViewController as! CreateEntryViewController
        presenter.saveCategory(category: selectedValue)
        }else{
            let selectedValue = projectsPassed[pickerViewOutlet.selectedRow(inComponent: (0))]
            
            let presenter = self.presentingViewController as! CreateEntryViewController
            presenter.saveProject(project: selectedValue)
        }
    }
}
