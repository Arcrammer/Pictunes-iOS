//
//  ViewController.swift
//  Ready
//
//  Created by Alexander Rhett Crammer on 10/11/15.
//  Copyright © 2015 HoA. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Outlets
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var welcomeMenu: UITableView!
    @IBOutlet weak var welcomeMenuStatusBarBackground: UIVisualEffectView!
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var fullNameField: ARBottomLineField!
    @IBOutlet weak var passwordField: ARBottomLineField!
    @IBOutlet weak var fieldContainer: UIView!
    @IBOutlet weak var fieldContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var fullNameFieldWidth: NSLayoutConstraint!
    @IBOutlet weak var passwordFieldWidth: NSLayoutConstraint!
    
    // MARK: Actions
    @IBAction func authenticateUser(sender: AnyObject) {
        // Fetch the API key
        self.fetchAPIKey()
        
        // Log the user out in the event they've already logged in
        self.deauthenticateUser({
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            // TODO: You should probably take all of this out of the
            //   self.deauthenticateUser() closure. Logging the user
            //   out before logging them back in is just for debugging
            
            // Send the credentials provided to the server
            if var providedUsername = self.fullNameField.text, var providedPassword = self.passwordField.text {
                // Trim whitespace from the input provided
                providedUsername = providedUsername.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                providedPassword = providedPassword.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
                // Authenticate the User
                if providedUsername != "" && providedPassword != "" {
                    
                    // The user has provided both a username and a password
                    let authenticationRequest = NSMutableURLRequest(URL: NSURL(string: "http://api.pictunes.dev/auth/login")!)
                    authenticationRequest.setValue(self.APIKey, forHTTPHeaderField: "X-Authorization")
                    authenticationRequest.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
                    authenticationRequest.HTTPMethod = "POST"
                    authenticationRequest.HTTPBody = "username=\(providedUsername)&password=\(providedPassword)".dataUsingEncoding(NSASCIIStringEncoding)
                    
                    // Send a request to authenticate the user
                    NSURLSession.sharedSession().dataTaskWithRequest(authenticationRequest, completionHandler: {
                        (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                        
                        print(NSString(data: data!, encoding: NSASCIIStringEncoding)!)
                        
                        // The request has loaded
                        if let authenticationResponse = response as? NSHTTPURLResponse {
                            if authenticationResponse.statusCode == 200 {
                                // The user has successfully logged in
                                print("Authenticated")
                                
                                // Store the response (It's JSON of the users' dashboard
                                // pictunes) and send the user to the FeedViewController
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.performSegueWithIdentifier("feedViewSegue", sender: self)
                                })
                            } else if authenticationResponse.statusCode == 401 {
                                // The credentials provided didn't match any users
                                let loginProbAlert = UIAlertController(title: "Whoops", message: "Those credentials didn't work.", preferredStyle: .Alert)
                                loginProbAlert.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
                                
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.presentViewController(loginProbAlert, animated: true, completion: nil)
                                })
                            }
                        }
                        
                        //                    if let responseData = data {
                        //                        do {
                        //                            // Try to serialise the JSON and store it for use later
                        //                            if let responseJSON = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.AllowFragments) as? Array<[String: AnyObject]> {
                        //                                // The user has logged in successfully. Remember this until they logout
                        //                                self.pictunes = responseJSON
                        //                                self.performSegueWithIdentifier("feedViewSegue", sender: "self")
                        //                            }
                        //                        } catch let parseProb {
                        //                            // The user isn't logged in. The server didn't send any JSON
                        //                            print(parseProb)
                        //                        }
                        //                    }
                    }).resume()
                } else {
                    // TODO: One of the fields were left empty, so
                    // we should make its' border red
                    
                    //                There's a bug that makes it really hard to do this, though.
                    //                You'd think you can just do this:
                    //                
                    //                self.fullNameField.layer.borderColor = UIColor.redColor().CGColor
                    //                
                    //                But this isn't enough. I've noticed however, that you can add like
                    //                2.5 to self.fullNameField.layer.borderWidth and the red shows, but
                    //                that initial bottom border is still there and I can't change its'
                    //                colour. I've tried putting that line on the main queue and all.
                    
                }
            }
        })
        
    }
    
    @IBAction func liftView(sender: AnyObject) {
        if self.liftedFieldsContainer == false {
            // The View has not Been Lifted
            self.view.layoutIfNeeded()
            UIView.animateWithDuration(0.25, animations: {
                () -> Void in
                
                // Make the Logo Wider; Move the Logo Up
                self.logoHeightConstraint.constant += 125
                self.logoWidthConstraint.constant += 125
                self.logoTopConstraint.constant -= 350
                
                // Update the View Constraint
                self.fieldContainerTopConstraint.constant += 75
                self.liftedFieldsContainer = true
                
                // Make the Fields Wider
                self.fullNameFieldWidth.constant += 50
                self.passwordFieldWidth.constant += 50
                
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func dismissWelcomeMenu(sender: AnyObject) {
        // Simulate a Tap on the Pancake Button; Dismiss the Welcome Menu
        self.pancakes!.sendActionsForControlEvents(UIControlEvents.TouchDown)
    }
    
    // MARK: Properties
    var APIKey = "",
    liftedFieldsContainer = false,
    pancakes: ARPancakeButton?,
    darkBackground = false,
    pictunes: Array<[String: AnyObject]>? = nil
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // TODO: Don't actually give every downloader access to the 'iAlexander' account
        self.fullNameField.text = "iAlexander"
        self.passwordField.text = "secret"
        
        // Pancake Button
        addPancakeButton()
        
        // Welcome Menu
        self.welcomeMenu.alpha = 0.0
        
        // Animations
        UIView.animateWithDuration(0.75, animations: {
            () -> Void in
            
            // Update the Background Color
            self.view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        if self.liftedFieldsContainer == true {
            lowerView()
        }
    }
    
    func lowerView() {
        if self.liftedFieldsContainer == true {
            // The View has not Been Lifted
            self.view.layoutIfNeeded()
            UIView.animateWithDuration(0.5, animations: {
                () -> Void in
                
                // Make the Logo Thinner; Move the Logo Down
                self.logoHeightConstraint.constant -= 125
                self.logoWidthConstraint.constant -= 125
                self.logoTopConstraint.constant += 350
                
                // Update the View Constraint
                self.fieldContainerTopConstraint.constant -= 75
                self.liftedFieldsContainer = false
                
                // Make the Fields Thinner
                self.fullNameFieldWidth.constant -= 50
                self.passwordFieldWidth.constant -= 50
                
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func addPancakeButton() {
        self.pancakes = ARPancakeButton()
        self.pancakes!.translatesAutoresizingMaskIntoConstraints = false
        self.pancakes!.addTarget(self, action: "toggleMenuVisibility", forControlEvents: UIControlEvents.TouchDown)
        self.view.addSubview(self.pancakes!)
        
        // Pancake Button Constraints
        self.view.addConstraint(NSLayoutConstraint(item: self.pancakes!,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0,
            constant: 45.0))
        self.view.addConstraint(NSLayoutConstraint(item: self.pancakes!,
            attribute: NSLayoutAttribute.Right,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Right,
            multiplier: 1.0,
            constant: -25.0))
        self.view.addConstraint(NSLayoutConstraint(item: self.pancakes!,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1.0,
            constant: 35.0))
        self.view.addConstraint(NSLayoutConstraint(item: self.pancakes!,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1.0,
            constant: 45.0))
        self.updateViewConstraints()
    }
    
    func deauthenticateUser(onCompletion: ((data: NSData?, response: NSURLResponse?, error: NSError?) -> (Void))? = nil) {
        let deauthRequest = NSURLRequest(URL: NSURL(string: "http://api.pictunes.dev/auth/logout")!)
        NSURLSession.sharedSession().dataTaskWithRequest(deauthRequest, completionHandler: onCompletion!).resume()
        print("Deauthenticated")
    }
    
    func toggleMenuVisibility() {
        if self.welcomeMenu.hidden == true {
            // Animate It
            UIView.animateWithDuration(0.35, animations: {
                () -> Void in
                
                // Make the Menu and Status Bar Background Opaque
                self.welcomeMenu.alpha = 1.0
                self.welcomeMenuStatusBarBackground.alpha = 1.0
            })
            
            // Display the Bloody Background
            self.welcomeMenu.hidden = false
            self.welcomeMenuStatusBarBackground.hidden = false
            
            // Change the Status Bar Colour
            self.darkBackground = true
            self.setNeedsStatusBarAppearanceUpdate()
        } else {
            // Fade to Transparency
            UIView.animateWithDuration(0.35, animations: {
                    () -> Void in
                    // Make the Menu and Status Bar Background Transparent
                    self.welcomeMenu.alpha = 0.0
                    self.welcomeMenuStatusBarBackground.alpha = 0.0
                }, completion: {
                    (completion: Bool) -> Void in
                    
                    // Get rid of the Bloody Background
                    self.welcomeMenuStatusBarBackground.hidden = true
                    self.welcomeMenu.hidden = true
                })
            
            // Change the Status Bar Colour
            self.darkBackground = false
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if self.darkBackground == true {
            // Make the Status Bar White when the Background is Dark
            return UIStatusBarStyle.LightContent
        } else {
            return UIStatusBarStyle.Default
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        switch identifier {
        case "feedViewSegue":
            return false
        default:
            return true
        }
    }
    
    func fetchAPIKey() {
        let keysPlist: NSDictionary?
        if let keysPlistPath = NSBundle.mainBundle().pathForResource("Keys", ofType: "plist") {
            keysPlist = NSDictionary(contentsOfFile: keysPlistPath)
            if let keys = keysPlist {
                self.APIKey = keys["API"] as! String
            }
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.returnKeyType == UIReturnKeyType.Next {
            self.view.viewWithTag(1)!.becomeFirstResponder()
        }
        return true
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)!
        // Revert to the Inactive Colour
        selectedCell.selected = false
        
        switch indexPath.row {
            case 0:
            self.performSegueWithIdentifier("registrationViewSegue", sender: self)
            case 1:
            self.performSegueWithIdentifier("forgottenPasswordViewSegue", sender: self)
            default:
            self.dismissWelcomeMenu(self)
        }
    }
    
    // MARK: UITableViewDataSource
    let choices = ["Create Account", "Forgot Password"]
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "choiceCell")
        cell.textLabel?.text = choices[indexPath.row]
        cell.backgroundColor = UIColor(red: 175/255, green: 14/255, blue: 20/255, alpha: 1)
        // Set the Active (Selected) Background Colour
        let background = UIView()
        background.backgroundColor = UIColor.redColor()
        cell.selectedBackgroundView = background
        cell.textLabel?.textColor = UIColor.whiteColor()
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choices.count
    }
}
