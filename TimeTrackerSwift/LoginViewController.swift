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
    
    var spinner:UIActivityIndicatorView!
    var absConnectionObj = ABSConnection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        login.layer.cornerRadius = 10.0
        login.clipsToBounds = true
        login.layer.borderWidth = 1
        login.layer.borderColor = UIColor.black.cgColor
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "loginBackground.png")!)
        spinner = UIActivityIndicatorView()
        spinner.frame = CGRect(x:(self.view.frame.width/2)-25, y:(self.view.frame.height/2)-25, width:50, height:50)
        spinner.alpha = 0
        spinner.color = UIColor.white
        view.addSubview(spinner)
        
        testInternetConnection()
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {self.view.layoutIfNeeded()}, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == username{
            self.password.becomeFirstResponder()
        }
        return false
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
        }
    }
    
    func invalidCredentials(){
        print("Invalid Credentials")
        let alert = UIAlertController(title: "Invalid Credentials", message: "Please check the Credentials you entered", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
            print(response!)
            let arrayWithArray = [temp]
            ABSSessionData().projectInfo = arrayWithArray
            presentProjectsViewController(array: temp)
            spinner.stopAnimating()
            UIView.animate(withDuration: 0.2, animations: {self.spinner.alpha = 0})
        }else{
            print("Failed to get projects")
        }
    }
}
