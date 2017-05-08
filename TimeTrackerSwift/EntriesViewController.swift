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
    var daysSections = [String:Any]()
    var selectedWeek = ""
    var dateSelected = ""
    var selectedWeekID:NSNumber = 0
    
    override func viewDidLoad(){
        super.viewDidLoad()
        displayCurrentWeek()
        dateSelected = DateConverter.getCurrentDate()
        spinner = UIActivityIndicatorView()
        spinner.frame = CGRect(x:(self.view.frame.width/2)-25, y:(self.view.frame.height/2)-25, width:50, height:50)
        spinner.transform = CGAffineTransform(scaleX: 2.0, y: 2.0);
        spinner.alpha = 0
        view.addSubview(spinner)
        spinner.color = UIColor.white
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
        refreshGeneralDataForSelectedWeek()
        
        if UIDevice.current.orientation.isLandscape {
            presentPopoverGraph()
        }
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.portrait
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
        let tempEndDay = DateConverter.getThrusdayForWeek(selectedDate: tempDate)
        let endDate = dateFormatter.string(from: tempEndDay as Date)
        let tempStartDay = DateConverter.getPreviousFridayForWeek(selectedDate:tempDate)
        let startDate = dateFormatter.string(from: tempStartDay as Date)
        date.setTitle(startDate + " - " + endDate,for: .normal)
    }
    
    func displayCurrentWeek(){
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        selectedDate = currentDate as NSDate
        let tempEndDay = DateConverter.getThrusdayForWeek(selectedDate: selectedDate)
        let endDate = dateFormatter.string(from: tempEndDay as Date)
        let tempStartDay = DateConverter.getPreviousFridayForWeek(selectedDate:selectedDate)
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
            array = daysSections["Friday"] as! [Any]!
        case 1:
            array = daysSections["Saturday"] as! [Any]!
        case 2:
            array = daysSections["Sunday"] as! [Any]!
        case 3:
            array = daysSections["Monday"] as! [Any]!
        case 4:
            array = daysSections["Tuesday"] as! [Any]!
        case 5:
            array = daysSections["Wednesday"] as! [Any]!
        case 6:
            array = daysSections["Thursday"] as! [Any]!
            
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
            if daysSections["Friday"] != nil{
                tempArray = daysSections["Friday"] as! [Entry]
                if tempArray.count == 0{
                    
                }else{
                    sectionTitle = "Friday"
                }
            }
        case 1:
            if daysSections["Saturday"] != nil{
                tempArray = daysSections["Saturday"] as! [Entry]
                if tempArray.count == 0{
                    
                }else{
                    sectionTitle = "Saturday"
                }
            }
        case 2:
            if daysSections["Sunday"] != nil{
                tempArray = daysSections["Sunday"] as! [Entry]
                if tempArray.count == 0{
                    
                }else{
                    sectionTitle = "Sunday"
                }
            }
        case 3:
            if daysSections["Monday"] != nil{
                tempArray = daysSections["Monday"] as! [Entry]
                if tempArray.count == 0{
                    
                }else{
                    sectionTitle = "Monday"
                }
            }
        case 4:
            if daysSections["Tuesday"] != nil{
                tempArray = daysSections["Tuesday"] as! [Entry]
                if tempArray.count == 0{
                    
                }else{
                    sectionTitle = "Tuesday"
                }
            }
        case 5:
            if daysSections["Wednesday"] != nil{
                tempArray = daysSections["Wednesday"] as! [Entry]
                if tempArray.count == 0{
                    
                }else{
                    sectionTitle = "Wednesday"
                }
            }
        case 6:
            if daysSections["Thursday"] != nil{
                tempArray = daysSections["Thursday"] as! [Entry]
                if tempArray.count == 0{
                    
                }else{
                    sectionTitle = "Thursday"
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
            if entry.startHour.characters.contains("m"){
                cell.entryDurationOutlet.text = time + " (" + entry.startHour.lowercased() + " → " + entry.endHour.lowercased() + ")"
            }else{
                cell.entryDurationOutlet.text = time + " (" + TimeConverter.eraseLeading0(timeStr:TimeConverter.formatTime(time: entry.startHour as String)) + " → " + TimeConverter.eraseLeading0(timeStr:TimeConverter.formatTime(time: entry.endHour as String)) + ")"
            }
            cell.numberOutlet.text = String(indexPath.row + 1)
        }
        return cell
    }
    
    func getEntriesForDayAtIndexPath(indexPath:NSIndexPath) -> [Entry]{
        var array = [Entry]()
        
        switch(indexPath.section){
        case 0:
            array = daysSections["Friday"] as! [Entry]
        case 1:
            array = daysSections["Saturday"] as! [Entry]
        case 2:
            array = daysSections["Sunday"] as! [Entry]
        case 3:
            array = daysSections["Monday"] as! [Entry]
        case 4:
            array = daysSections["Tuesday"] as! [Entry]
        case 5:
            array = daysSections["Wednesday"] as! [Entry]
        case 6:
            array = daysSections["Thursday"] as! [Entry]
        default:
            return []
        }
        return array
    }
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func refreshGeneralDataForSelectedWeek(){
        spinner.startAnimating()
        UIView.animate(withDuration: 0.2, animations: {self.spinner.alpha = 1})
        getSelectedWeekID(dateStr: dateSelected)
    }
    
    func getSelectedWeekID(dateStr:String){
        let tempDate = DateConverter.stringToDate(dateStr: dateStr) as NSDate
        ABSConnection.shared().fetchWeekEndingsCompletionBlock{ (response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if ((response) != nil) {
                let id = DateConverter.getidFromResponse(selectedDate: DateConverter.getFridayForWeek(selectedDate: tempDate), response: response as! [[String : Any]]) as NSNumber!
                self.selectedWeekID = id!
                print(self.selectedWeekID)
                ABSSessionData().selectedWeekID = id
                self.refreshSelectedWeekData(id: id!)
                self.displaySelectedWeek(dateStr: DateConverter().dayIntervalForWeekEnding(date: tempDate))
                UIView.animate(withDuration: 0.2, animations: {self.spinner.alpha = 0})
                self.spinner.stopAnimating()
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
            spinner.startAnimating()
            UIView.animate(withDuration: 0.2, animations: {self.spinner.alpha = 1})
            
            ABSConnection.shared().fetchTimeEntries(forWeek: id, completionBlock:{ (response) in
                //check if response
                if let resp = response{
                    UIView.animate(withDuration: 0.2, animations: {self.spinner.alpha = 0})
                    self.spinner.stopAnimating()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                  
                    if resp.count != 0{
                        for dict in resp{
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
                }else{
                    //response is nil
//                    ABSSessionData().timeEntriesInfo = nil
//                    self.entries.removeAll()
//                    self.tableView.reloadData()
//                    let alert = UIAlertController(title: "Error", message: "Restart Application", preferredStyle: UIAlertControllerStyle.alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
//                        (success) in
//                        
                        let storyboard = UIStoryboard(name:"Main", bundle:nil)
                        let presentingVC = storyboard.instantiateViewController(withIdentifier: "login") as! LoginViewController
                        
                        //set variables if needed
                        presentingVC.setRestart()
                        
                        self.present(presentingVC, animated: true, completion: nil)
                        
                   // }))
                   // self.present(alert, animated: true, completion: nil)
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
        let xPosition = date.frame.minX + (date.frame.width/2)
        let yPosition = date.frame.maxY
        
        // get a reference to the view controller for the popover
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "calendar") as! CalendarViewController
        
        popController.dateBtn = true
        if date.titleLabel?.text?.isEmpty == false{
            let dateStr = date.titleLabel?.text
            let tempArray = dateStr?.components(separatedBy: " ")
            let tempArray2 = tempArray?[2].components(separatedBy: "/")
            
            popController.passedStartingMonth = Int((tempArray2?[0])!)!
            popController.passedStartingYear = Int((tempArray2?[2])!)!
        }
        
        // set the presentation style
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        // set up the popover presentation controller
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = self.view
        popController.preferredContentSize = CGSize(width: 300, height: 316)
        popController.popoverPresentationController?.sourceRect = CGRect(x: xPosition, y: yPosition, width: 0, height: 0)
        
        // present the popover
        self.present(popController, animated: true, completion: nil)
    }
    
    @IBAction func logoutBtn(_ sender: UIBarButtonItem) {
        ABSSessionData().clear()
        ABSConnection.shared().logOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addNewEntry(_ sender: UIBarButtonItem) {
        let createEntryVC:CreateEntryViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createEntry") as! CreateEntryViewController
        createEntryVC.projectsArray = projectsArray
        present(createEntryVC, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditEntrySegue"{
            let createEntryVC:CreateEntryViewController = segue.destination as! CreateEntryViewController
            createEntryVC.projectsArray = projectsArray
            createEntryVC.titleVC = "Edit Entry"
            let selectedIndex = (tableView.indexPathForSelectedRow! as NSIndexPath)
            let selectedRow = (tableView.indexPathForSelectedRow! as NSIndexPath).row
            let tempArr = getEntriesForDayAtIndexPath(indexPath: selectedIndex)
            createEntryVC.activeEntry = tempArr[selectedRow]
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Gill Sans", size: 22)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        var array = [Entry]()
        
        switch(indexPath.section){
        case 0:
            array = daysSections["Friday"] as! [Entry]
        case 1:
            array = daysSections["Saturday"] as! [Entry]
        case 2:
            array = daysSections["Sunday"] as! [Entry]
        case 3:
            array = daysSections["Monday"] as! [Entry]
        case 4:
            array = daysSections["Tuesday"] as! [Entry]
        case 5:
            array = daysSections["Wednesday"] as! [Entry]
        case 6:
            array = daysSections["Thursday"] as! [Entry]
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
        }
    }
    
    func deleteEntryWithId(entryId:NSNumber){
        spinner.startAnimating()
        UIView.animate(withDuration: 0.2, animations: {self.spinner.alpha = 1})
        ABSConnection.shared().deleteEntry(withId: entryId, completionBlock: { (reponse) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            UIView.animate(withDuration: 0.2, animations: {self.spinner.alpha = 0})
            self.spinner.stopAnimating()
            let iD = self.selectedWeekID
            self.refreshSelectedWeekData(id: iD)
        })
    }
    
    func getTimeArray()->[Double]{
        var times:[Double]!
        var days = [String:Any]()
        
        for key in daysSections{
            var sum:Float = 0
            
            for entry in key.value as! [Entry]{
                sum += entry.duration
            }
            days[key.key] = Double(sum)
        }
        times = [days["Friday"] as! Double, days["Saturday"] as! Double, days["Sunday"] as! Double, days["Monday"] as! Double, days["Tuesday"] as! Double, days["Wednesday"] as! Double, days["Thursday"] as! Double]
        return times
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func orientationChanged(){
        if self.isViewLoaded && (self.view.window != nil){
            if UIDevice.current.orientation.isLandscape == true {
                if self.presentedViewController is CalendarViewController{
                    dismiss(animated: true, completion: nil)
                }
                presentPopoverGraph()
            }
        }else{
            if UIDevice.current.orientation.isLandscape == true {
                return
            }else{
                if self.presentedViewController is GraphViewController{
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func presentPopoverGraph(){
        // get a reference to the view controller for the popover
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "graphView") as! GraphViewController
        
        let times:[Double]!
        if entries.count == 0{
            times = []
        }else{
            times = getTimeArray()
        }
        popController.weekTimes = times
        
        // set up the popover presentation controller
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = self.view
        popController.popoverPresentationController?.sourceRect = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: 0, height: 0)
        popController.preferredContentSize = CGSize(width: view.bounds.width, height: view.bounds.height)
        
        // present the popover
        self.present(popController, animated: true, completion: nil)
    }
}
