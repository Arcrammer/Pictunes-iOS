//
//  RegistrationViewController.swift
//  Ready
//
//  Created by Alexander Rhett Crammer on 10/14/15.
//  Copyright © 2015 HoA. All rights reserved.
//

import UIKit
import MobileCoreServices

class RegistrationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /* Outlets */
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailField: ARBottomLineField!
    @IBOutlet weak var fullNameField: ARBottomLineField!
    @IBOutlet weak var passwordField: ARBottomLineField!
    @IBOutlet weak var verificationField: ARBottomLineField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var scrollViewFieldsContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageUploadChooserView: UIVisualEffectView!
    
    /* Actions */
    @IBAction func chooseImage(sender: AnyObject) {
        // Configure the Image Picker
        self.picker = UIImagePickerController()
        self.picker!.delegate = self
        self.picker!.mediaTypes = [kUTTypeImage as String]
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            // Allow the User to Choose Taking a Photo or Choosing One
            self.showChoiceView()
        } else {
            // The Device's Camera isn't Available
            self.picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            // Show the Picker View
            self.presentViewController(self.picker!, animated: true, completion: nil)
        }
    }
    
    @IBAction func dismissPickerChoiceView(sender: AnyObject) {
        self.dismissChoiceView()
    }
    
    @IBAction func attemptToCreateAccount(sender: AnyObject) {
        // The User has Tapped the 'Create' Button
    }
    
    @IBAction func dismissView(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func showLibrary(sender: AnyObject) {
        print("Show Library")
        // The Device's Camera is Available
        self.picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        // Show the Picker View
        self.presentViewController(self.picker!, animated: true, completion: nil)
    }
    
    @IBAction func showCamera(sender: AnyObject) {
        // The Device's Camera is Available
        self.picker!.sourceType = UIImagePickerControllerSourceType.Camera
        
        // Show the Picker View
        self.presentViewController(self.picker!, animated: true, completion: nil)
    }
    
    /* Properties */
    var keyboardShowing = false,
    darkBackground = false,
    picker: UIImagePickerController?
    
    /* Methods */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Allow Swiping from the Left to Dismiss the View
        self.navigationController!.interactivePopGestureRecognizer?.delegate = nil
        
        // Update Profile Image Appearance
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
        self.profileImage.layer.borderColor = UIColor.blackColor().CGColor
        self.profileImage.layer.borderWidth = 1.5
        
        // Dynamically Change Scroll View Constraints When Keyboard Shows and Hides
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setKeyboardVisibilityTrue", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setKeyboardVisibilityFalse", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardVisiblityChanged:", name: UIKeyboardDidChangeFrameNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if self.darkBackground == true {
            // Make the Status Bar White when the Background is Dark
            return UIStatusBarStyle.LightContent
        } else {
            return UIStatusBarStyle.Default
        }
    }
    
    func showChoiceView() {
        // Give the user the choice of uploading or selecting an image
        
        // Make it Invisible
        self.imageUploadChooserView!.alpha = 0
        
        // Show it in the View
        self.imageUploadChooserView.hidden = false
        
        // Animate the new View into the Viewport
        UIView.animateWithDuration(0.15, animations: {
            () -> Void in
            self.imageUploadChooserView!.alpha = 1
            self.backButton.alpha = 0
        })
        
        // Change the Status Bar Colour
        self.darkBackground = true
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func dismissChoiceView() {
        // Dismiss the Image Chooser View
        UIView.animateWithDuration(0.15, animations: {
            () -> Void in
            self.imageUploadChooserView!.alpha = 1
            self.backButton.alpha = 1
        }, completion: {
            (complete: Bool) -> Void in
            // Hide it Again
            self.imageUploadChooserView.hidden = true
            
            // Change the Status Bar Colour
            self.darkBackground = false
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    /* Observers */
    func setKeyboardVisibilityTrue() {
        // Store the Fact that a Keyboard is no Longer Showing; This is necessary
        // because 'UIKeyboardWillShowNotification' is called again
        // after switching the keyboard type (i.e. from 'Email' to
        // 'ASCII Compatible', although 'UIKeyboardWillHideNotificiation'
        // is not called again. This means one of these two methods will
        // be called twice effectively causing undesirable graphic probs
        //
        self.keyboardShowing = true
    }
    
    func setKeyboardVisibilityFalse() {
        self.keyboardShowing = false
    }
    
    func keyboardVisiblityChanged(notification: NSNotification?) {
        if self.keyboardShowing == false {
            // Remove Bottom Spacing to the View Within the Scroll View
            self.scrollViewFieldsContainerBottomConstraint.constant -= notification!.userInfo![UIKeyboardFrameBeginUserInfoKey]!.CGRectValue!.size.height
        } else {
            // Add Bottom Spacing to the View Within the Scroll View
            self.scrollViewFieldsContainerBottomConstraint.constant += notification!.userInfo![UIKeyboardFrameBeginUserInfoKey]!.CGRectValue!.size.height
        }
    }
    
    /* UIImagePickerControllerDelegate Methods */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        // Set the Image and Dismiss the Choice and Picker Views
        self.profileImage.image = image
        self.dismissChoiceView()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
