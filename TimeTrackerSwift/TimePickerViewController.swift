//
//  TimeViewController.swift
//  TimeTrackerSwift
//
//  Created by Stefan Auvergne on 12/14/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import UIKit
import Foundation

class TimePickerViewController: UIViewController, UIPickerViewDelegate, UIGestureRecognizerDelegate{
    var strTimeSaved = ""
    var endTimeSaved = ""
    @IBOutlet weak var timePickerViewOutlet: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if strTimeSaved != ""{
        setTimeInPicker(timeStr: strTimeSaved)
        }
        if endTimeSaved != ""{
            setTimeInPicker(timeStr: endTimeSaved)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(PickerViewController.pickerTapped))
        self.timePickerViewOutlet.addGestureRecognizer(tap)
        tap.delegate = self
    }
    
    func setTimeInPicker(timeStr:String){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        let temp = TimeConverter.changeTo24HourFormat(string:timeStr)
        let date = dateFormatter.date(from: temp)
        timePickerViewOutlet.date = date!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pickerTapped(){
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func timePickerView(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let selectedTime = formatter.string(from: timePickerViewOutlet.date).lowercased()
        let presenter = self.presentingViewController as! CreateEntryViewController
        presenter.saveTime(time: selectedTime)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
