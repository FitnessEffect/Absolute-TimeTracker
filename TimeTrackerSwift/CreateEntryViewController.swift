//
//  CreateEntryViewController.swift
//  TimeTrackerSwift
//
//  Created by Stefan Auvergne on 12/12/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import UIKit

class CreateEntryViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITextViewDelegate, UIScrollViewDelegate{
    
    @IBOutlet weak var navigationTitle: UINavigationItem!
    @IBOutlet weak var projectTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    @IBOutlet weak var durationResult: UILabel!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var endTimeBtn: UIButton!
    @IBOutlet weak var scrollView: ScrollView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var textEntries = [Entry]()
    var entry:Entry!
    var selectedDate:String = ""
    var selectedTime:String = ""
    var currentTime:String = ""
    var startTimeSelected = false
    var endTimeSelected = false
    var latestEnteredStartTime = "latestEnteredStartTime"
    var latestEnteredEndTime = "latestEnteredEndTime"
    var activeField: UITextView?
    var activeTextField: UITextField?
    var activeProject:Project!
    var activeCategory:ProjectCategory!
    var activeEntry:Entry!
    var projectsArray:[Project]!
    var spinner:UIActivityIndicatorView!
    var titleVC = ""
    var entryID = 0
    var blockSelectProject = false
    var blockSelectCategory = false
    var day:String = "day"
    var dayCheck:Bool = false
    var setDayBool = "setDayBool"
    
    
    let prefs = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForKeyboardNotifications()
        
        if titleVC != ""{
            navigationTitle.title = titleVC
        }
        
        if let temp = prefs.object(forKey: "setDayBool"){
            dayCheck = temp as! Bool
        }
        
        if prefs.object(forKey: day) != nil{
            //erase latestEnteredEndTime if new day
            if (String(describing: prefs.object(forKey: day)!) != DateConverter.getCurrentDate()){
                dayCheck = false
                prefs.set(dayCheck, forKey:"setDayBool")
                selectedTime = ""
                prefs.set(selectedTime, forKey: latestEnteredEndTime)
            }
        }
        
        if let setStartT = prefs.object(forKey: latestEnteredEndTime) as? String{
            startTimeTextField.text = setStartT
        }

        if startTimeTextField.text != "" && endTimeTextField.text != ""{
            durationResult.text = String(TimeConverter.formatDurationFromSeconds(durationInSeconds: TimeConverter.calculateDuration(startTime: startTimeTextField.text!, endTime: endTimeTextField.text!)))
            checkForNegativeDuration()
        }
        
        spinner = UIActivityIndicatorView()
        spinner.startAnimating()
        spinner.frame = CGRect(x:(self.view.frame.width/2)-25, y:(self.view.frame.height/2)-25, width:50, height:50)
        spinner.alpha = 0
        view.addSubview(spinner)
        
        save.layer.cornerRadius = 5.0
        save.clipsToBounds = true
        save.layer.borderWidth = 1
        save.layer.borderColor = UIColor.black.cgColor
        
        descriptionTextView.layer.cornerRadius = 7.0
        descriptionTextView.clipsToBounds = true
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        
        projectTextField.layer.cornerRadius = 7.0
        projectTextField.clipsToBounds = true
        projectTextField.layer.borderWidth = 1
        projectTextField.layer.borderColor = UIColor.black.cgColor
        
        categoryTextField.layer.cornerRadius = 7.0
        categoryTextField.clipsToBounds = true
        categoryTextField.layer.borderWidth = 1
        categoryTextField.layer.borderColor = UIColor.black.cgColor
        
        dateTextField.layer.cornerRadius = 7.0
        dateTextField.clipsToBounds = true
        dateTextField.layer.borderWidth = 1
        dateTextField.layer.borderColor = UIColor.black.cgColor
        
        startTimeTextField.layer.cornerRadius = 7.0
        startTimeTextField.clipsToBounds = true
        startTimeTextField.layer.borderWidth = 1
        startTimeTextField.layer.borderColor = UIColor.black.cgColor
        
        endTimeTextField.layer.cornerRadius = 7.0
        endTimeTextField.clipsToBounds = true
        endTimeTextField.layer.borderWidth = 1
        endTimeTextField.layer.borderColor = UIColor.black.cgColor
        
        if activeProject != nil{
            setProjectField(project: activeProject)
        }
        if activeEntry != nil{
            setEntryFields(entry: activeEntry)
        }
        if dateTextField.text == ""{
            dateTextField.text = DateConverter.getCurrentDate()
        }
        scrollView.setParent(sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.deregisterFromKeyboardNotifications()
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.portrait
    }
    
    func dismissKeyboard(){
        descriptionTextView.resignFirstResponder()
    }
    
    func setProjectField(project:Project){
        projectTextField.text = project.projectName
        if categoryTextField.text != nil{
            projectTextField.isEnabled = false
        }
    }
    
    func setEntryFields(entry:Entry){
        entryID = Int(entry.entryID)
        projectTextField.text = entry.projectName as String
        for project in projectsArray{
            if entry.projectName == project.projectName{
                saveProject(project: project)
            }
        }
        
        categoryTextField.text = entry.category as String
        for category in activeProject.projectCategories{
            if category.abbreviation == categoryTextField.text!{
                saveCategory(category: category)
            }
        }
        if categoryTextField.text != nil{
            categoryTextField.isEnabled = false
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let unformattedDate = DateConverter.getDateFromUnixString(str: entry.entryDate as String)
        let formattedStrDate = dateFormatter.string(from: unformattedDate as Date)
        
        dateTextField.text = formattedStrDate
        startTimeTextField.text = TimeConverter.formatTime(time: entry.startHour as String)
        endTimeTextField.text = TimeConverter.formatTime(time: entry.endHour as String)
        durationResult.text = TimeConverter.formatDurationFromSeconds(durationInSeconds: TimeConverter.calculateDuration(startTime: entry.startHour, endTime: entry.endHour))
        descriptionTextView.text = entry.descript as String
        descriptionLabelActivation()
    }
    
    func updateActiveEntry(){
        var dictionary = [String:Any]()
        dictionary["CategoryName"] = categoryTextField.text
        dictionary["Duration"] = Float(TimeConverter.calculateDuration(startTime: startTimeTextField.text!, endTime: endTimeTextField.text!))
        dictionary["Description"] = descriptionTextView.text
        dictionary["ProjectName"] = projectTextField.text
        dictionary["EntryLogID"] = -1
        dictionary["CategoryID"] = activeCategory.categoryID
        dictionary["IssueID"] = -1
        dictionary["ProjectID"] = activeProject.projectID
        dictionary["ModuleID"] = -1
        dictionary["CreationDate"] = DateConverter.getCurrentDate()
        dictionary["EntryDate"] = dateTextField.text
        dictionary["StartHour"] = startTimeTextField.text
        dictionary["EndHour"] = endTimeTextField.text
        dictionary["EntryDate"] = dateTextField.text
        
        activeEntry = Entry(dictionary: dictionary)
        
    }
    
    func testInternetConnection() -> Bool{
        let reachability = Reachability()
        if reachability?.currentReachabilityString == "No Connection"{
            print("Error: NO INTERNET CONNECTION")
            return false
        }else if reachability?.currentReachabilityString == "WiFi"{
            print("Success: We Got Wifi")
            return true
        }else if reachability?.currentReachabilityString == "Cellular"{
            print("Success: We Got Cellular")
            return true
        }else{
            return false
        }
    }
    
    @IBAction func save(_ sender: UIButton) {
        var flag = true
        if projectTextField.text == "" || categoryTextField.text == "" || startTimeTextField.text == "" || endTimeTextField.text == ""{
            flag = false
        }else{
            updateActiveEntry()
            
            //Input Validation
            if (activeEntry.descript == "" || self.durationResult.text == "Error" || activeProject.projectName == ""){
                flag = false
            }
        }
        if flag == false{
            if self.durationResult.text == "Error"{
                let alert = UIAlertController(title: "Invalid Entry Duration", message: "Please verify the time entered", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: "Entry Information Missing", message: "All fields are required", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }else{
            //check for empty string
            activeEntry.descript = descriptionTextView.text
            descriptionTextView.resignFirstResponder()
            
            //Get Task Duration
            let dateFormatterFirst = DateFormatter()
            dateFormatterFirst.dateFormat = "hh:mm a"
            let entryEndHour:Date =  dateFormatterFirst.date(from: activeEntry.endHour as String)!
            let entryStartHour:Date = dateFormatterFirst.date(from: activeEntry.startHour as String)!
            let timeInterval = Int(entryEndHour.timeIntervalSince(entryStartHour))
            self.activeEntry.duration = Float(timeInterval)/Float(3600)
            
            //Convert Date to 24h format
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            
            //get entry date
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            
            print(activeEntry.entryDate)
            print(activeEntry.creationDate)
            let timeInMilliseconds = ((formatter.date(from: activeEntry.entryDate as String))?.timeIntervalSince1970)!*1000
            let tempStr = String(timeInMilliseconds).components(separatedBy: ".")
            
            let wsDate = "/Date(\(tempStr[0]))/"
            
            var entry:[String:Any] = [:]
            entry["Description"] = activeEntry.descript
            entry["Duration"] = activeEntry.duration
            entry["CategoryID"] = activeEntry.categoryID
            entry["EndHour"] = activeEntry.endHour
            entry["EntryDate"] = wsDate
            entry["IssueID"] = 0
            entry["ModuleID"] = 0
            entry["ProjectID"] = activeEntry.projectID
            entry["StartHour"] = activeEntry.startHour
            entry["UserID"] = ABSConnection().returnId()!
            
            //JSON IN SWIFT
            var entryJSON:[String:String] = [:]
            if titleVC == "Edit Entry"{
                entryJSON = ["EntryId":String(entryID),"Description":activeEntry.descript as String, "Duration":String(activeEntry.duration), "CategoryID":String(describing: activeEntry.categoryID), "EndHour":activeEntry.endHour, "EntryDate":String(describing: wsDate), "IssueID":"0", "ModuleID":"0", "ProjectID":String(describing: activeEntry.projectID), "StartHour":activeEntry.startHour, "UserID":String(describing: ABSConnection().returnId()!)]
            }else{
                entryJSON = ["Description":activeEntry.descript as String, "Duration":String(activeEntry.duration), "CategoryID":String(describing: activeEntry.categoryID), "EndHour":activeEntry.endHour, "EntryDate":String(describing: wsDate), "IssueID":"0", "ModuleID":"0", "ProjectID":String(describing: activeEntry.projectID), "StartHour":activeEntry.startHour, "UserID":String(describing: ABSConnection().returnId()!)]
            }
            
            if testInternetConnection() == true{
                spinner.startAnimating()
                UIView.animate(withDuration: 0.2, animations: {self.spinner.alpha = 1})
                ABSConnection.shared().addTime(entryJSON, completionBlock:{ (success) in
                    UIView.animate(withDuration: 0.2, animations: {self.spinner.alpha = 0})
                    self.spinner.stopAnimating()
                    var alert:UIAlertController? = nil
                    
                    if(success){
                            self.dismiss(animated: true, completion: nil)
                    }else{
                        alert = UIAlertController(title: "Error", message: "Could not save the entry", preferredStyle: UIAlertControllerStyle.alert)
                        alert?.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert!, animated: true, completion: nil)
                    }
                })
            }else{
                let alert = UIAlertController(title: "No Internet Connection", message: "An active internet connection is required", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func saveDate(date:String){
        selectedDate = date
        dateTextField.text = selectedDate
    }
    
    func selectCategory(_ sender:UITextField){
        if projectTextField.text != ""{
            let xPosition = categoryTextField.frame.minX + (categoryTextField.frame.width/2)
            let yPosition = sender.frame.maxY
            // get a reference to the view controller for the popover
            
            let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            
            popController.setCategoriesForProject(project: activeProject)
            
            // set the presentation style
            popController.modalPresentationStyle = UIModalPresentationStyle.popover
            
            // set up the popover presentation controller
            popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
            popController.popoverPresentationController?.delegate = self
            popController.popoverPresentationController?.sourceView = self.view
            popController.popoverPresentationController?.sourceRect = CGRect(x: xPosition, y: yPosition, width: 0, height: 0)
            popController.preferredContentSize = CGSize(width: 355, height: 210)
            
            // present the popover
            self.present(popController, animated: true, completion: nil)
            
            popController.currentCategorySelection = categoryTextField.text
        }
    }
    
    func saveCategory(category:ProjectCategory){
        categoryTextField.text = category.categoryName
        //set active category
        activeCategory = category
    }
    
    func saveProject(project:Project){
        projectTextField.text = project.projectName
        //set active project
        activeProject = project
    }
    
    func selectProject(_ sender:UITextField){
        let xPosition = projectTextField.frame.minX + (projectTextField.frame.width/2)
        let yPosition = sender.frame.maxY
        
        // get a reference to the view controller for the popover
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        popController.setProjects(array: projectsArray)
        
        // set the presentation style
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        // set up the popover presentation controller
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = self.view
        popController.popoverPresentationController?.sourceRect = CGRect(x: xPosition, y: yPosition, width: 0, height: 0)
        popController.preferredContentSize = CGSize(width: 355, height: 210)
        
        // present the popover
        self.present(popController, animated: true, completion: nil)
        
        popController.currentProjectSelection = projectTextField.text
    }
    
    func saveTime(time:String){
        selectedTime = time
        if startTimeSelected == true{
            //Note:Start time does not need to be saved
            startTimeTextField.text = selectedTime
        }else if endTimeSelected == true{
            //end time saved as start time
            if dayCheck == false{
            prefs.set(DateConverter.getCurrentDate(), forKey: day)
            print(DateConverter.getCurrentDate())
            print(String(describing: prefs.object(forKey: day)!))
            dayCheck = true
            prefs.set(dayCheck, forKey:"setDayBool")
            }
            prefs.set(selectedTime, forKey: latestEnteredEndTime)
            endTimeTextField.text = selectedTime
        }
        durationResult.text = TimeConverter.formatDurationFromSeconds(durationInSeconds:TimeConverter.calculateDuration(startTime: startTimeTextField.text!, endTime: endTimeTextField.text!))
        checkForNegativeDuration()
    }
    
    func selectDate(_ sender: UITextField){
        let xPosition = dateTextField.frame.minX + (dateTextField.frame.width/2)
        let yPosition = sender.frame.maxY
        // get a reference to the view controller for the popover
        
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "calendar") as! CalendarViewController
        
        // set the presentation style
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        // set up the popover presentation controller
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = self.view
        popController.preferredContentSize = CGSize(width: 300, height: 316)
        popController.popoverPresentationController?.sourceRect = CGRect(x: xPosition, y: yPosition, width: 0, height: 0)
        
        if dateTextField.text?.isEmpty == false{
            let dateStr = dateTextField.text
            let tempArray = dateStr?.components(separatedBy: "/")
            popController.passedStartingMonth = Int((tempArray?[0])!)!
            popController.passedStartingYear = Int((tempArray?[2])!)!
        }
        
        // present the popover
        self.present(popController, animated: true, completion: nil)
    }
    
    func selectTime(_ sender: UITextField){
        startTimeSelected = false
        endTimeSelected = false
        
        let xPosition = startTimeTextField.frame.minX + (startTimeTextField.frame.width/2)
        
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "time") as! TimePickerViewController
        
        if sender.tag == 1{
            popController.currentTimeSaved = startTimeTextField.text
        }
        if sender.tag == 2{
            popController.currentTimeSaved = endTimeTextField.text
        }
        // set the presentation style
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        // set up the popover presentation controller
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = self.view
        popController.preferredContentSize = CGSize(width: 250, height: 205)
        popController.popoverPresentationController?.sourceRect = CGRect(x: xPosition, y: sender.frame.maxY, width: 0, height: 0)
        
        if sender.tag == 1{
            if (startTimeTextField.text?.isEmpty == false){
                popController.strTimeSaved = (startTimeTextField.text?.lowercased())!
            }
        }
        if sender.tag == 2{
            if (endTimeTextField.text?.isEmpty == false){
                popController.endTimeSaved = (endTimeTextField.text?.lowercased())!
            }
        }
        // present the popover
        self.present(popController, animated: true, completion: nil)
        
        if sender.tag == 1{
            startTimeSelected = true
        }
        if sender.tag == 2{
            endTimeSelected = true
        }
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        durationResult.text = TimeConverter.formatDurationFromSeconds(durationInSeconds:TimeConverter.calculateDuration(startTime: startTimeTextField.text!, endTime: endTimeTextField.text!))
        checkForNegativeDuration()
    }
    
    func checkForNegativeDuration(){
        if durationResult.text?.characters.first == "-"{
            let errorStr = "Error"
            let rangeOfStr = (errorStr as NSString).range(of: errorStr)
            let attributedString = NSMutableAttributedString(string: errorStr)
            attributedString.setAttributes([NSForegroundColorAttributeName : UIColor.red], range: rangeOfStr)
            durationResult.attributedText = attributedString
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        let info: NSDictionary  = notification.userInfo! as NSDictionary
        let keyboardSize = (info.value(forKey: UIKeyboardFrameEndUserInfoKey) as AnyObject).cgRectValue.size
        let contentInsets:UIEdgeInsets  = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        self.scrollView.setContentOffset(CGPoint(x:0, y:(keyboardSize.height)), animated: true)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        activeField = textView
        descriptionLabelActivation()
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        activeField = nil
        descriptionLabelActivation()
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)
        blockSelectProject = true
        blockSelectCategory = true
    }
    
    func descriptionLabelActivation(){
        if activeField != nil || descriptionTextView.text != ""{
            descriptionLabel.isHidden = true
        }else{
            descriptionLabel.isHidden = false
        }
    }
    
    @IBAction func endTime(_ sender: UIButton) {
        if activeField == nil{
            let temp = TimeConverter.getCurrentTime().lowercased()
            endTimeTextField.text = temp
            endTimeSelected = true
            durationResult.text = TimeConverter.formatDurationFromSeconds(durationInSeconds:TimeConverter.calculateDuration(startTime: startTimeTextField.text!, endTime: endTimeTextField.text!))
            checkForNegativeDuration()
            saveTime(time: temp)
        }
    }
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
