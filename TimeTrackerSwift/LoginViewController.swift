//
//  ViewController.swift
//  TimeTrackerSwift
//
//  Created by Stefan Auvergne on 12/12/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var switchBox: UISwitch!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var spinner:UIActivityIndicatorView!
    var absConnectionObj = ABSConnection()
    var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        login.layer.cornerRadius = 10.0
        login.clipsToBounds = true
        login.layer.borderWidth = 1
        login.layer.borderColor = UIColor.black.cgColor
        
        password.layer.cornerRadius = 10.0
        password.clipsToBounds = true
        password.layer.borderWidth = 1
        password.layer.borderColor = UIColor.black.cgColor
        
        username.layer.cornerRadius = 10.0
        username.clipsToBounds = true
        username.layer.borderWidth = 1
        username.layer.borderColor = UIColor.black.cgColor
        
        spinner = UIActivityIndicatorView()
        spinner.frame = CGRect(x:(self.view.frame.width/2)-25, y:(self.view.frame.height/2)-25, width:50, height:50)
        spinner.alpha = 0
        spinner.transform = CGAffineTransform(scaleX: 2.0, y: 2.0);
        spinner.color = UIColor.white
        view.addSubview(spinner)
        
        username.delegate = self
        password.delegate = self
        testInternetConnection()
        
        registerForKeyboardNotifications()
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.portrait
    }
    
    func dismissKeyboard(){
        username.resignFirstResponder()
        password.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switchBox.isOn = ABSSessionData.rememberMeIsOn()
        if switchBox.isOn{
            //retrieve info
            if let name = ABSSessionData.getStoredUsername(){
                username.text = name
            }
            if let password = ABSSessionData.getStoredPassword(){
                self.password.text = password
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func testInternetConnection(){
        let reachability = Reachability()
        if reachability?.currentReachabilityString == "No Connection"{
            print("Error: NO INTERNET CONNECTION")
        }else if reachability?.currentReachabilityString == "WiFi"{
            print("Success: We Got Wifi")
            absConnectionObj.internetConnection = true
        }else if reachability?.currentReachabilityString == "Cellular"{
            print("Success: We Got Cellular")
            absConnectionObj.internetConnection = true
        }
    }
    
    func invalidCredentials(){
        print("Invalid Credentials")
        let alert = UIAlertController(title: "Invalid Credentials", message: "Please check the Credentials you entered", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        spinner.stopAnimating()
        UIView.animate(withDuration: 0.2, animations: {self.spinner.alpha = 0})
    }
    
    @IBAction func login(_ sender: UIButton) {
        if (!absConnectionObj.internetConnection){
            print("No Internet Connection")
            let alert = UIAlertController(title: "No Internet Connection", message: "An active internet connection is required", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }else if(username.text?.characters.count)! == 0{
            print("Invalid Username")
            let alert = UIAlertController(title: "Invalid Username", message: "Please check the Username you entered", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }else if(password.text?.characters.count)! == 0{
            print("Invalid Password")
            let alert = UIAlertController(title: "Invalid Password", message: "Please check the password you entered", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }else {
            if switchBox.isOn{
                ABSSessionData.setStoredPassword(password.text!, forUsername: username.text!)
            }else{
                ABSSessionData.setStoredPassword(nil, forUsername: nil)
            }
            ABSSessionData.setRememberMeOn(switchBox.isOn)
            spinner.startAnimating()
            UIView.animate(withDuration: 0.2, animations: {self.spinner.alpha = 1})
            
            //check username and password
            ABSConnection.shared().login(withUsername: username.text!, password: password.text!, completionBlock:loginCompletion)
        }
    }
    
    func loginCompletion(success:Bool){
        if success{
            getProjects()
        }else{
            invalidCredentials()
        }
    }
    
    func presentProjectsViewController(array:[Project]){
        let storyboard = UIStoryboard(name:"Main", bundle:nil)
        let presentingVC = storyboard.instantiateViewController(withIdentifier: "entriesVC") as! EntriesViewController
        
        //set variables if needed
        presentingVC.projectsArray = array
        
        self.present(presentingVC, animated: true, completion: nil)
    }
    
    func getProjects(){
        ABSConnection.shared().fetchProjectInfoCompletionBlock(projectCompletion)
    }
    
    func projectCompletion(response:[Any]?){
        var temp:[Project] = []
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if response != nil && (response?.count)! > 0{
            for dict in response!{
                let p = Project(dictionary: dict as! [String : Any])
                temp.append(p)
            }
            ABSSessionData().projectInfo = [temp]
            presentProjectsViewController(array: temp)
            spinner.stopAnimating()
            UIView.animate(withDuration: 0.2, animations: {self.spinner.alpha = 0})
        }else{
            print("Failed to get projects")
        }
    }
    
    func keyboardWasShown(notification: NSNotification){
        //let info: NSDictionary  = notification.userInfo! as NSDictionary
        //let keyboardSize = (info.value(forKey: UIKeyboardFrameEndUserInfoKey) as AnyObject).cgRectValue.size
        //let contentInsets:UIEdgeInsets  = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        //scrollView.contentInset = contentInsets
        //scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)
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
}
