//
//  TimeViewController.swift
//  TimeTrackerSwift
//
//  Created by Stefan Auvergne on 12/14/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import UIKit

class TimePickerViewController: UIViewController, UIPickerViewDelegate{
    
    var selectedTime = ""
    var createEntryObj:CreateEntryViewController!
    
    @IBOutlet weak var timePickerViewOutlet: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func timePickerView(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let selectedTime = formatter.string(from: timePickerViewOutlet.date)
        print(selectedTime)
        let presenter = self.presentingViewController as! CreateEntryViewController

        presenter.saveTime(time: selectedTime)
    }    
}
