//
//  ProjectDetailViewController.swift
//  TimeTrackerSwift
//
//  Created by Stefan Auvergne on 12/27/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import UIKit

class EntriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var date: UIButton!
    
    var projectsArray:[Project]!
    var entries = [Entry]()
    var selectedProject:Project!
    var spinner = UIActivityIndicatorView()
    var entryCount = 0
    var selectedDate = NSDate()
    var resultSearchController = UISearchController()
    var daysSections = [String:Any]()
    var selectedWeek = ""
    var dateSelected = ""
    var selectedWeekID:NSNumber = 0
    
    override func viewDidLoad(){
        super.viewDidLoad()
        displayCurrentWeek()
        
        spinner = UIActivityIndicatorView()
        spinner.frame = CGRect(x:(self.view.frame.width/2)-25, y:(self.view.frame.height/2)-25, width:50, height:50)
        spinner.alpha = 0
        view.addSubview(spinner)
        
        date.layer.cornerRadius = 10.0
        date.clipsToBounds = true
        date.layer.borderWidth = 1
        date.layer.borderColor = UIColor.black.cgColor
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(EntriesViewController.orientationChanged), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        refreshGeneralData()
        //displayCurrentWeek()
        //tableView.reloadData()
    }
    
    func setNewDate(dateStr:String){
        dateSelected = dateStr
        getSelectedWeekID(dateStr: dateStr)
        selectedWeekDisplay(dateStr: dateStr)
    }
    
    func selectedWeekDisplay(dateStr:String){
        
        let tempDate = DateConverter.stringToDate(dateStr: dateStr) as NSDate
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let tempEndDay = DateConverter.getFridayForWeek(selectedDate: tempDate)
        let endDate = dateFormatter.string(from: tempEndDay as Date)
        
        let tempStartDay = DateConverter.getPreviousSaturdayForWeek(selectedDate:tempDate)
        let startDate = dateFormatter.string(from: tempStartDay as Date)
        
        date.setTitle(startDate + " - " + endDate,for: .normal)
    }
    
    func displayCurrentWeek(){
        
        let currentDate = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        selectedDate = currentDate as NSDate
        let tempEndDay = DateConverter.getFridayForWeek(selectedDate: selectedDate)
        let endDate = dateFormatter.string(from: tempEndDay as Date)
        
        let tempStartDay = DateConverter.getPreviousSaturdayForWeek(selectedDate:selectedDate)
        let startDate = dateFormatter.string(from: tempStartDay as Date)
        
        date.setTitle(startDate + " - " + endDate,for: .normal)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
            var array:[Any]?
            
            switch(section){
            case 0:
                array = daysSections["Saturday"] as! [Any]!
            case 1:
                array = daysSections["Sunday"] as! [Any]!
            case 2:
                array = daysSections["Monday"] as! [Any]!
            case 3:
                array = daysSections["Tuesday"] as! [Any]!
            case 4:
                array = daysSections["Wednesday"] as! [Any]!
            case 5:
                array = daysSections["Thursday"] as! [Any]!
            case 6:
                array = daysSections["Friday"] as! [Any]!
            default:
                return 0;
            }
            if array == nil{
                return 0
            }
            return array!.count;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var sectionTitle = ""
        var tempArray = [Entry]()
        
        switch(section){
        case 0:
            if daysSections["Saturday"] != nil{
                tempArray = daysSections["Saturday"] as! [Entry]
                if tempArray.count == 0{
                    
                }else{
                    sectionTitle = "Saturday"
                }
            }
        case 1:
            if daysSections["Sunday"] != nil{
                tempArray = daysSections["Sunday"] as! [Entry]
                if tempArray.count == 0{
                    
                }else{
                    sectionTitle = "Sunday"
                }
            }
        case 2:
            if daysSections["Monday"] != nil{
                tempArray = daysSections["Monday"] as! [Entry]
                if tempArray.count == 0{
                    
                }else{
                    sectionTitle = "Monday"
                }
            }
        case 3:
            if daysSections["Tuesday"] != nil{
                tempArray = daysSections["Tuesday"] as! [Entry]
                if tempArray.count == 0{
                    
                }else{
                    sectionTitle = "Tuesday"
                }
            }
        case 4:
            if daysSections["Wednesday"] != nil{
                tempArray = daysSections["Wednesday"] as! [Entry]
                if tempArray.count == 0{
                    
                }else{
                    sectionTitle = "Wednesday"
                }
            }
        case 5:
            if daysSections["Thursday"] != nil{
                tempArray = daysSections["Thursday"] as! [Entry]
                if tempArray.count == 0{
                    
                }else{
                    sectionTitle = "Thursday"
                }
            }
        case 6:
            if daysSections["Friday"] != nil{
                tempArray = daysSections["Friday"] as! [Entry]
                if tempArray.count == 0{
                    
                }else{
                    sectionTitle = "Friday"
                }
            }
        default:
            sectionTitle = ""
        }
        return sectionTitle
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryCell", for: indexPath) as! EntryTableViewCell
        
        var tempArr = getEntriesForDayAtIndexPath(indexPath: indexPath as NSIndexPath)
        if tempArr.count != 0{
            let entry:Entry = tempArr[indexPath.row]
            cell.projectNameOutlet.text =  entry.projectName as String
            let duration = TimeConverter.calculateDuration(startTime: entry.startHour, endTime: entry.endHour)
            let time = TimeConverter.formatDurationFromSeconds(durationInSeconds: duration)
            cell.entryDurationOutlet.text = time + " (" + TimeConverter.formatTime(time: entry.startHour as String) + " → " + TimeConverter.formatTime(time: entry.endHour as String) + ")"
            cell.numberOutlet.text = String(indexPath.row + 1)
        }
        
        return cell
    }
    
    func getEntriesForDayAtIndexPath(indexPath:NSIndexPath) -> [Entry]{
        var array = [Entry]()
        
        switch(indexPath.section){
        case 0:
            array = daysSections["Saturday"] as! [Entry]
            
        case 1:
            array = daysSections["Sunday"] as! [Entry]
            
        case 2:
            array = daysSections["Monday"] as! [Entry]
            
        case 3:
            array = daysSections["Tuesday"] as! [Entry]
            
        case 4:
            array = daysSections["Wednesday"] as! [Entry]
            
        case 5:
            array = daysSections["Thursday"] as! [Entry]
            
        case 6:
            array = daysSections["Friday"] as! [Entry]
            
        default:
            return []
        }
        
        return array
    }
    
    //    func categoriesAbbreviationToFull(string:String)->String{
    //        var newString = ""
    //
    //        if string == "DBUG"{
    //            newString = "Debugging"
    //        }else if string == "DEV"{
    //            newString = "Development"
    //        }else if string == "DSN"{
    //            newString = "Design"
    //        }else if string == "PM"{
    //            newString = "Project Management"
    //        }else if string == "TEST"{
    //            newString = "Testing"
    //        }
    //
    //        return newString
    //    }
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func refreshGeneralData(){
        UIView.animate(withDuration: 0.2, animations: {self.spinner.alpha = 1})
        getCurrentWeekID()
    }
    
    func getCurrentWeekID(){
        spinner = UIActivityIndicatorView()
        
        UIView.animate(withDuration: 0.2, animations: {self.spinner.alpha = 1})
        
        let date = NSDate()
        let currentDate = DateConverter().dateAt00(date: date)
        ABSConnection.shared().fetchWeekEndingsCompletionBlock{ (response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if ((response) != nil) {
                
                let id = DateConverter.getidFromResponse(selectedDate: DateConverter.getFridayForWeek(selectedDate: currentDate), response: response as! [[String : Any]]) as NSNumber!
                self.selectedWeekID = id!
                ABSSessionData().selectedWeekID = id
                self.refreshSelectedWeekData(id: id!)
                self.displaySelectedWeek(dateStr: DateConverter().dayIntervalForWeekEnding(date: currentDate))
                UIView.animate(withDuration: 0.2, animations: {self.spinner.alpha = 0})
            }
        }
    }
    
    func getSelectedWeekID(dateStr:String){
        spinner = UIActivityIndicatorView()
        
        UIView.animate(withDuration: 0.2, animations: {self.spinner.alpha = 1})
        
        let tempDate = DateConverter.stringToDate(dateStr: dateStr) as NSDate
        ABSConnection.shared().fetchWeekEndingsCompletionBlock{ (response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if ((response) != nil) {
                
                let id = DateConverter.getidFromResponse(selectedDate: DateConverter.getFridayForWeek(selectedDate: tempDate), response: response as! [[String : Any]]) as NSNumber!
                self.selectedWeekID = id!
                ABSSessionData().selectedWeekID = id
                self.refreshSelectedWeekData(id: id!)
                self.displaySelectedWeek(dateStr: DateConverter().dayIntervalForWeekEnding(date: tempDate))
                UIView.animate(withDuration: 0.2, animations: {self.spinner.alpha = 0})
            }
        }
    }
    
    func displaySelectedWeek(dateStr:String){
        selectedWeek = dateStr
    }
    
    func refreshSelectedWeekData(id:NSNumber){
        entries.removeAll()
        daysSections.removeAll()
        
        if id == 0{
            let alert = UIAlertController(title: "Invalid Date! ", message: "Please select another week!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            entries.removeAll()
            self.tableView.reloadData()
        }else{
            UIView.animate(withDuration: 0.2, animations: {self.spinner.alpha = 1})
            ABSConnection.shared().fetchTimeEntries(forWeek: id, completionBlock:{ (response) in
                UIView.animate(withDuration: 0.2, animations: {self.spinner.alpha = 0})
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if response?.count != 0{
                    for dict in response!{
                        let entry = Entry.init(dictionary: dict as! [String : Any])
                        self.entries.append(entry)
                    }
                    self.daysSections = self.groupEntriesByDay(entriesPassed: self.entries) as! [String : Any]
                    ABSSessionData().timeEntriesInfo = response
                    self.tableView.reloadData()
                }else{
                    ABSSessionData().timeEntriesInfo = nil
                    self.entries.removeAll()
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func groupEntriesByDay(entriesPassed:[Entry])-> NSDictionary{
        var dict = [String:[Entry]]()
        let monday = [Entry]()
        let tuesday = [Entry]()
        let wednesday = [Entry]()
        let thursday = [Entry]()
        let friday = [Entry]()
        let saturday = [Entry]()
        let sunday = [Entry]()
        
        dict["Monday"] = monday
        dict["Tuesday"] = tuesday
        dict["Wednesday"] = wednesday
        dict["Thursday"] = thursday
        dict["Friday"] = friday
        dict["Saturday"] = saturday
        dict["Sunday"] = sunday
        
        for entry in entriesPassed{
            let dayName = DateConverter.getNameForDay(entryDate: entry.entryDate as String)
            var temp:[Entry]{
                get{
                    return dict[dayName]!
                }
                set(newValue){
                    dict[dayName] = newValue
                }
            }
            temp.append(entry)
        }
        return dict as NSDictionary
    }
    
    @IBAction func changeDate(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showView", sender: self)
    }
    
    @IBAction func logoutBtn(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier :"login") as! LoginViewController
        self.present(loginVC, animated: true)
        ABSSessionData().clear()
        ABSConnection.shared().logOut()
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AddEntrySegue"{
            let createEntryVC:CreateEntryViewController = segue.destination as! CreateEntryViewController
            createEntryVC.projectsArray = projectsArray
        }else if segue.identifier == "EditEntrySegue"{
            let createEntryVC:CreateEntryViewController = segue.destination as! CreateEntryViewController
            createEntryVC.projectsArray = projectsArray
            createEntryVC.titleVC = "Edit Entry"
            let selectedIndex = (tableView.indexPathForSelectedRow! as NSIndexPath)
            let selectedRow = (tableView.indexPathForSelectedRow! as NSIndexPath).row
            let tempArr = getEntriesForDayAtIndexPath(indexPath: selectedIndex)
            createEntryVC.activeEntry = tempArr[selectedRow]
            
        }else if segue.identifier == "showView"{
             let xPosition = date.frame.minX + date.frame.width/9
            let vc = segue.destination as! CalendarViewController
            vc.dateBtn = true
            vc.preferredContentSize = CGSize(width: 250, height: 250)
            vc.popoverPresentationController?.sourceRect = CGRect(x: xPosition, y: date.frame.minY/3, width: 0, height: 0)
            let popController = vc.popoverPresentationController
            if popController != nil{
                popController?.delegate = self
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        var array = [Entry]()
        
        switch(indexPath.section){
        case 0:
            array = daysSections["Saturday"] as! [Entry]
            
        case 1:
            array = daysSections["Sunday"] as! [Entry]
            
        case 2:
            array = daysSections["Monday"] as! [Entry]
            
        case 3:
            array = daysSections["Tuesday"] as! [Entry]
            
        case 4:
            array = daysSections["Wednesday"] as! [Entry]
            
        case 5:
            array = daysSections["Thursday"] as! [Entry]
            
        case 6:
            array = daysSections["Friday"] as! [Entry]
            
        default:
            array = []
        }
        
        let selectedEntry = array[indexPath.row]
        
        if editingStyle == .delete {
            let deleteAlert = UIAlertController(title: "Delete this entry?", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let tagID = selectedEntry.entryID
            deleteAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(controller) in
                self.deleteEntryWithId(entryId:tagID)
            
            }))
            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
            self.present(deleteAlert, animated: true, completion: nil)
            
           // entries.remove(at: indexPath.row)
           // tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func deleteEntryWithId(entryId:NSNumber){
        UIView.animate(withDuration: 0.2, animations: {self.spinner.alpha = 1})
        ABSConnection.shared().deleteEntry(withId: entryId, completionBlock: { (reponse) in
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
            UIView.animate(withDuration: 0.2, animations: {self.spinner.alpha = 0})
            let iD = self.selectedWeekID
            self.refreshSelectedWeekData(id: iD)
        })
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func orientationChanged(){
        
        if UIDevice.current.orientation.isLandscape == true {
            print("Landscape")
            
            // get a reference to the view controller for the popover
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "graphView") as! GraphViewController
            //popController.setProjects(array: projectsArray)
            // set the presentation style
            //popController.modalPresentationStyle = UIModalPresentationStyle.popover
           
            
            // set up the popover presentation controller
            //popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
            popController.popoverPresentationController?.delegate = self
            popController.popoverPresentationController?.sourceView = self.view
            popController.popoverPresentationController?.sourceRect = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: 0, height: 0)
            popController.preferredContentSize = CGSize(width: view.bounds.width, height: view.bounds.height)
            
            // present the popover
            self.present(popController, animated: true, completion: nil)

            
        } else {
            print("Portrait")
            self.dismiss(animated: true, completion: nil)
            
        }
    }
}
