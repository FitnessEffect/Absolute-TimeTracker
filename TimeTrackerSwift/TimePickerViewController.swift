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
    var currentTimeSaved:String!

    
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var timePickerViewOutlet: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if strTimeSaved != ""{
            setTimeInPicker(timeStr: strTimeSaved)
        }
        if endTimeSaved != ""{
            setTimeInPicker(timeStr: endTimeSaved)
        }

        selectBtn.layer.cornerRadius = 13.0
        selectBtn.clipsToBounds = true
        selectBtn.layer.borderWidth = 1
        selectBtn.layer.borderColor = UIColor.black.cgColor
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
    
    @IBAction func selectTime(_ sender: UIButton) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let selectedTime = formatter.string(from: timePickerViewOutlet.date).lowercased()
        let presenter = self.presentingViewController as! CreateEntryViewController
        presenter.saveTime(time: selectedTime)
        self.dismiss(animated: true, completion: nil)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
