//
//  GraphViewWindow.swift
//  TimeTrackerSwift
//
//  Created by Stefan Auvergne on 1/17/17.
//  Copyright © 2017 com.example. All rights reserved.
//

import UIKit

class GraphViewWindow: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun", ""]
    var arrayOfYvalues:[Double] = []
    var yMax:Double = 30.0
    var yMin:Double = 0
    var xMin:Double = 0
    var xMax:Double = 7
    var screenHeight:Double = 600.0
    var screenWidth:Double = 380.0
    var xUnit:Double = 7
    var yUnit:Double = 5
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
       // plotFunction()
        drawAxis()
    }
    
    override func layoutSubviews() {
        screenHeight = Double(self.frame.size.height)
        screenWidth = Double(self.frame.size.width)
    }
    
    func drawAxis(){
        UIColor.black.set()
        
        //draw xAxis
        let xPath = UIBezierPath()
        xPath.move(to: CGPoint(x:40, y:screenHeight - 40))
        xPath.addLine(to: CGPoint(x:screenWidth - 40 , y:screenHeight - 40))
        xPath.stroke()
        
        //draw yAxis
        let yPath = UIBezierPath()
        yPath.move(to: CGPoint(x:40, y:40))
        yPath.addLine(to: CGPoint(x:40, y:screenHeight - 40))
        yPath.stroke()
        
        let xSpacing = (screenWidth - 80)/xUnit
        
        for i in Int(xMin)...Int(xMax) {
            //Draw x axis dashes
            
            xPath.move(to: CGPoint(x:40 + Double(i) * xSpacing, y:screenHeight - 42))
            xPath.addLine(to: CGPoint(x:40 + Double(i) * xSpacing, y:screenHeight - 38))
            xPath.stroke()
            
            
            //Draw x axis day names
            let day = dayNames[i]
            let dayRect = CGRect(x: Double((70 + CGFloat(Double(i) * xSpacing))), y: Double(screenHeight - 30), width: 70, height: 50)
            let font = UIFont(name: "Gill Sans", size: 15)
            let dayFontAttribute = [NSFontAttributeName: font!]
            day.draw(in: dayRect, withAttributes: dayFontAttribute)
        }

        
        let ySpacing = (screenHeight - 80)/yUnit
        
        for i in Int(yMin)...Int(yMax){
            //Draw y axis dashes
            yPath.move(to: CGPoint(x:38, y:screenHeight - 40 - Double(i) * ySpacing))
            yPath.addLine(to: CGPoint(x:42, y:screenHeight - 40 - Double(i) * ySpacing))
            yPath.stroke()
            
            //Draw y axis Numbers
            let number = String(i)
            
                let font = UIFont(name: "Gill Sans", size: 10)
                let numberTwoRect = CGRect(x: 32 , y: CGFloat(screenHeight - 46) - CGFloat(Double(i) * ySpacing), width: 50, height: 50)
                let numberTwoAttributes = [
                    NSFontAttributeName: font!]
                number.draw(in: numberTwoRect,
                            withAttributes:numberTwoAttributes)
            
        }
    }

}
