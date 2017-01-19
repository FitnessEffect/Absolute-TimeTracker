//
//  TimeConverter.swift
//  TimeTrackerSwift
//
//  Created by Stefan Auvergne on 1/4/17.
//  Copyright © 2017 com.example. All rights reserved.
//

import Foundation

class TimeConverter{
    
    static func getCurrentTime() -> String{
        var tempMinuteStr = ""
        let date = NSDate()
        let formatter = DateFormatter()
        
        let calendar = NSCalendar.current
        var hour = calendar.component(.hour, from: date as Date)
        var symbol = ""
        if hour > 11{
            if hour == 12{
                symbol = formatter.calendar.pmSymbol
            }else{
                hour = hour - 12
                symbol = formatter.calendar.pmSymbol
            }
        }else{
            symbol = formatter.calendar.amSymbol
        }
        
        let minute = calendar.component(.minute, from: date as Date)
        if minute < 10 {
            tempMinuteStr = "0" + String(minute)
        }else{
            tempMinuteStr = String(minute)
        }
        let tempStr = String(hour) + ":" + tempMinuteStr + " " + symbol
        return tempStr
    }
    
    static func formatTime(time:String)-> String{
        let tempArray = time.components(separatedBy: ":")
        var newTimeStr = ""
        if Int(tempArray[0])! > 12 {
            let newTime = Int(tempArray[0])!-12
            newTimeStr = String(newTime) + ":" + tempArray[1] + " PM"
        }else if Int(tempArray[0])! < 12{
            if tempArray[0] == "00"{
                newTimeStr = "12" + ":" + tempArray[1] +   " AM"
            }else{
                newTimeStr = tempArray[0] + ":" + tempArray[1] + " AM"
            }
        }else if Int(tempArray[0])! == 12{
            newTimeStr = tempArray[0] + ":" + tempArray[1] + " PM"
        }
        return newTimeStr
    }
    
    static func changeTo24HourFormat(string:String)->String{
        var formattedStr = ""
        
        let tempArray = string.components(separatedBy: " ")
        let tempArray2 = tempArray[0].components(separatedBy: ":")
        if tempArray.last == "PM"{
            let formattedHour = Int(tempArray2[0])! + 12
            formattedStr = String(formattedHour) + ":" + tempArray2[1]
        }else{
            if tempArray2[0].characters.count == 1{
                formattedStr = "0" + tempArray2[0] + ":" + tempArray2[1]
            }else{
                formattedStr = tempArray2[0] + ":" + tempArray2[1]
            }
        }
        return formattedStr
    }
    
    static func changeToAmPmFormat(timeStr:String) ->String{
        if timeStr.characters.count == 5{
            let tempArray = timeStr.components(separatedBy: ":")
            if Int(tempArray[0])! > 12{
                let tempHour = Int(tempArray[0])! - 12
                return String(tempHour) + ":" + tempArray[1] + " PM"
            }else{
                return tempArray[0] + ":" + tempArray[1] + " AM"
            }
        }else{
            return timeStr
        }
    }
    
    static func formatDuration(timeStr:String)->String{
        let tempArray = timeStr.components(separatedBy: ".")
        if tempArray[0] == "0" && tempArray[1] == "00"{
            return "0"
        }
        if tempArray.first == "0"{
            let tempArray2 = tempArray[1].components(separatedBy: "0")
            return tempArray2.last! + "min"
        }else if tempArray.last == "00"{
            return tempArray.first! + "h"
            
        }else{
            return tempArray.first! + "h" + " " + tempArray.last! + "min"
        }
    }
    
    static func calculateDuration(startTime:String, endTime:String)-> Int{
        var intInterval = 0
        let formattedStartTime = changeToAmPmFormat(timeStr: startTime)
        let formattedEndTime = changeToAmPmFormat(timeStr: endTime)
        if formattedStartTime.isEmpty == false && formattedEndTime.isEmpty == false{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            
            let startT =  dateFormatter.date(from: formattedStartTime)
            let endT = dateFormatter.date(from: formattedEndTime)
            
            let interval = endT?.timeIntervalSince(startT!)
            intInterval = Int(interval!)
        }
        return intInterval
    }
    
    static func formatDurationFromSeconds(durationInSeconds:Int)-> String{
        //let seconds = intInterval % 60
        let minutes = (durationInSeconds / 60) % 60
        let hours = (durationInSeconds / 3600)
        var tempStr = ""
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        
        
        if hours == 0 && minutes == 0{
            tempStr = "0"
        }else if hours == 0{
            tempStr = String(format: "%02dmin", minutes)
            
        }else if minutes == 0{
            tempStr = String(format: "%02dh", hours)
        }else{
            tempStr = String(format: "%02dh %02dmin", hours, minutes)
        }
        
        if tempStr == "0"{
            return "0"
        }
        if tempStr.characters.first == "0"{
            tempStr.characters.removeFirst()
            return tempStr
        }
        return tempStr
    }
}
