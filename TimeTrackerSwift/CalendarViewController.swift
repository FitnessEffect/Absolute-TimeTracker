//
//  CalendarViewController.swift
//  TimeTrackerSwift
//
//  Created by Stefan Auvergne on 12/12/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import Foundation
import UIKit

class CalendarViewController:UIViewController{
    
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var monthTitle: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var selectedMonth = 0
    var selectedYear = 0
    var dayBoxBtn:UIButton! = nil
    var buttonArray = [UIButton]()
    var CreateEntryObj = CreateEntryViewController()
    var startingMonth = 0
    var dateBtn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.layer.cornerRadius = 10.0
        calendarView.clipsToBounds = true
        var currentMonth = getCurrentMonth()
        if startingMonth != 0{
            currentMonth = startingMonth
        }
        let currentYear = getCurrentYear()
        selectedYear = currentYear
        createButtonDays(month: currentMonth)
        
    }
    
    func getCurrentMonth() -> Int{
        let date = NSDate()
        let calendar = NSCalendar.current
        let month = calendar.component(.month, from: date as Date)
        return month
    }
    
    func getDaysInMonth(monthNum:Int, year:Int) -> Int{
        let calendar = NSCalendar.current
        let dateComponents = DateComponents(year:year, month: monthNum)
        let date = calendar.date(from: dateComponents)
        let range = calendar.range(of: .day, in: .month, for: date!)
        let numOfDays = (range?.count)! as Int
        return numOfDays
    }
    
    func getCurrentYear() -> Int{
        let date = NSDate()
        let calendar = NSCalendar.current
        let year = calendar.component(.year, from: date as Date)
        yearLabel.text = String(year)
        return year
    }
    
    @IBAction func nextBtn(_ sender: UIButton) {
        selectedMonth = selectedMonth + 1
        if selectedMonth == 13{
            selectedMonth = 1
            selectedYear = selectedYear + 1
        }
        yearLabel.text = String(selectedYear)
        createButtonDays(month: selectedMonth)
    }
    
    @IBAction func previousBtn(_ sender: UIButton) {
        selectedMonth = selectedMonth - 1
        if selectedMonth == 0{
            selectedMonth = 12
            selectedYear = selectedYear - 1
        }
        yearLabel.text = String(selectedYear)
        createButtonDays(month: selectedMonth)
    }
    
    func pressedDay(sender: UIButton!) -> String{
        let btnNum = sender.tag
        var monthStr = ""
        var btnStr = ""
        
        print(String(selectedMonth))
        if selectedMonth < 10 {
            monthStr = "0" + String(selectedMonth)
        }else{
            monthStr = String(selectedMonth)
        }
        print(String(btnNum))
        if btnNum < 10 {
            btnStr = "0" + String(btnNum)
        }else{
            btnStr = String(btnNum)
        }
        print(String(selectedYear))
        let date = monthStr + "/" + btnStr + "/" + String(selectedYear)
        print(date)
        if dateBtn == true{
            let presenter = self.presentingViewController as! EntriesViewController
            presenter.setNewDate(dateStr: date)
            dateBtn = false
        }else{
            
            let presenter = self.presentingViewController as! CreateEntryViewController
            presenter.saveDate(date: date)
        }
        self.dismiss(animated: true, completion: nil)
        
        return date
    }
    
    func createButtonDays(month:Int){
        selectedMonth = month
        let monthStr = months[month-1]
        monthTitle.text = monthStr
        
        if dayBoxBtn != nil{
            for element in buttonArray{
                element.removeFromSuperview()
            }
            buttonArray.removeAll()
        }
        
        var xPosition = 0
        var yPosition = 48
        
        let numOfdays = getDaysInMonth(monthNum: month, year: 2015)
        print(numOfdays)
        for index in 1...numOfdays{
            dayBoxBtn = UIButton()
            dayBoxBtn.frame = CGRect(x:xPosition, y:yPosition, width:35, height:40)
            buttonArray.append(dayBoxBtn)
            calendarView.addSubview(dayBoxBtn)
            dayBoxBtn.setTitle(String(index), for: .normal)
            
            if yPosition == 89 || yPosition == 171{
                dayBoxBtn.backgroundColor = UIColor.gray
            }else{
                dayBoxBtn.backgroundColor = UIColor.lightGray
            }
            
            dayBoxBtn.tag = index
            dayBoxBtn.addTarget(self, action: #selector(CalendarViewController.pressedDay(sender:)), for: .touchUpInside)
            xPosition = xPosition + 36
            
            if index % 7 == 0 && index > 0{
                yPosition += 41
                xPosition = 0
            }
        }
    }
}
