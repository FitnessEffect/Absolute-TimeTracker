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
        if time.characters.contains("m"){
            return time
        }else{
            let tempArray = time.components(separatedBy: ":")
            var newTimeStr = ""
            if Int(tempArray[0])! > 12 {
                let newTime = Int(tempArray[0])!-12
                newTimeStr = String(newTime) + ":" + tempArray[1] + " pm"
            }else if Int(tempArray[0])! < 12{
                if tempArray[0] == "00"{
                    newTimeStr = "12" + ":" + tempArray[1] +   " am"
                }else{
                    newTimeStr = tempArray[0] + ":" + tempArray[1] + " am"
                }
            }else if Int(tempArray[0])! == 12{
                newTimeStr = tempArray[0] + ":" + tempArray[1] + " pm"
            }
            return newTimeStr
        }
    }
    
    static func changeTo24HourFormat(string:String)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let date = dateFormatter.date(from: string)
        dateFormatter.dateFormat = "HH:mm"
        let date24 = dateFormatter.string(from: date!)
        return date24
    }
    
    static func changeToAmPmFormat(timeStr:String) ->String{
        if timeStr.characters.count == 5{
            let tempArray = timeStr.components(separatedBy: ":")
            if Int(tempArray[0])! >= 12{
                if Int(tempArray[0]) == 12{
                    return tempArray[0] + ":" + tempArray[1] + " pm"
                }else{
                    let tempHour = Int(tempArray[0])! - 12
                    return String(tempHour) + ":" + tempArray[1] + " pm"
                }
            }else{
                return tempArray[0] + ":" + tempArray[1] + " am"
            }
        }else{
            return timeStr
        }
    }
    
    static func eraseLeading0(timeStr:String) -> String{
        var tempStr = ""
        if timeStr.characters.first == "0"{
            let temp = timeStr.components(separatedBy: ":")
            let temp2 = temp[0].components(separatedBy: "0")
            tempStr = temp2[1] + ":" + temp[1]
            return tempStr
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
        let formattedStartTime:String!
        let formattedEndTime:String!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        if startTime.characters.contains("m"){
            formattedStartTime = startTime
            formattedEndTime = endTime
        }else{
            formattedStartTime = changeToAmPmFormat(timeStr: startTime)
            formattedEndTime = changeToAmPmFormat(timeStr: endTime)
        }
        if formattedStartTime.isEmpty == false && formattedEndTime.isEmpty == false{
            let startT =  dateFormatter.date(from: formattedStartTime)
            let endT = dateFormatter.date(from: formattedEndTime)
            let interval = endT?.timeIntervalSince(startT!)
            intInterval = Int(interval!)
        }
        return intInterval
    }
    
    static func formatDurationFromSeconds(durationInSeconds:Int)-> String{
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
