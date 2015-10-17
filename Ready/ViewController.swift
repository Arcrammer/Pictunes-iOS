//
//  ViewController.swift
//  Ready
//
//  Created by Alexander Rhett Crammer on 10/11/15.
//  Copyright © 2015 HoA. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    /* Outlets */
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
    
    /* Actions */
    @IBAction func authenticateUser(sender: AnyObject) {
        
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
    
    /* Properties */
    var liftedFieldsContainer = false
    var pancakes: ARPancakeButton?
    var darkBackground = false
    
    /* Methods */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
    
    /* UITextFieldDelegate */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.returnKeyType == UIReturnKeyType.Next {
            self.view.viewWithTag(1)!.becomeFirstResponder()
        }
        return true
    }
    
    /* UITableViewDelegate */
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
    
    /* UITableViewDataSource */
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
