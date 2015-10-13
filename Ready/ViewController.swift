//
//  ViewController.swift
//  Ready
//
//  Created by Alexander Rhett Crammer on 10/11/15.
//  Copyright © 2015 HoA. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    /* Outlets */
    @IBOutlet weak var menu: UITableView!
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var fullNameField: ARBottomLineField!
    @IBOutlet weak var passwordField: ARBottomLineField!
    @IBOutlet weak var continueButton: ARButton!
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
                
                // Move the Logo Up
                self.logoTopConstraint.constant -= 250
                
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
    
    /* Properties */
    var liftedFieldsContainer = false
    
    /* Methods */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Pancake Button
        let pancakes = addPancakeButton()
        
        // Attach Listener
        pancakes.addTarget(self, action: "toggleMenu", forControlEvents: UIControlEvents.TouchDown)
        
        // Animations
        UIView.animateWithDuration(0.35, animations: {
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
                
                // Move the Logo Down
                self.logoTopConstraint.constant += 250
                
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
    
    func addPancakeButton() -> ARPancakeButton {
        let pancakes = ARPancakeButton()
        pancakes.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(pancakes)
        
        // Pancake Button Constraints
        self.view.addConstraint(NSLayoutConstraint(item: pancakes,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0,
            constant: 45.0))
        self.view.addConstraint(NSLayoutConstraint(item: pancakes,
            attribute: NSLayoutAttribute.Right,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Right,
            multiplier: 1.0,
            constant: -25.0))
        self.view.addConstraint(NSLayoutConstraint(item: pancakes,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1.0,
            constant: 35.0))
        self.view.addConstraint(NSLayoutConstraint(item: pancakes,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1.0,
            constant: 45.0))
        self.updateViewConstraints()
        return pancakes
    }
    
    func toggleMenu() {
        if self.menu.hidden == true {
            // Show the Menu
            self.menu.hidden = false
        } else {
            // Hide the Menu
            self.menu.hidden = true
        }
    }
}
