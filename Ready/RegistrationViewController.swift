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
    @IBOutlet weak var scrollViewFieldsContainerBottomConstraint: NSLayoutConstraint!
    
    /* Actions */
    @IBAction func chooseImage(sender: AnyObject) {
        // Allow the User to Choose Taking a Photo or Choosing One
//        self.showChoiceView()
        
        // Animate the new View into the Viewport
//        self.imageChoiceView!.alpha = 0
//        UIView.animateWithDuration(0.15, animations: {
//            () -> Void in
//            self.imageChoiceView!.alpha = 1
//        })
        
        // Change the Status Bar Colour
        self.darkBackground = true
        self.setNeedsStatusBarAppearanceUpdate()
        
        // Profile Image Tap Action
        let profilePhotoPicker = UIImagePickerController()
        profilePhotoPicker.delegate = self
        profilePhotoPicker.mediaTypes = [kUTTypeImage as String]
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            // The Device's Camera is Available
            profilePhotoPicker.sourceType = UIImagePickerControllerSourceType.Camera
        } else {
            // The Device's Camera isn't Available
            profilePhotoPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        
        // Have the User Choose an Image
        self.presentViewController(profilePhotoPicker, animated: true, completion: nil)
    }
    
    @IBAction func attemptToCreateAccount(sender: AnyObject) {
        // The User has Tapped the 'Create' Button
    }
    
    @IBAction func dismissView(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    /* Properties */
    var keyboardShowing = false,
    imageChoiceView: ARImageChoiceView?,
    darkBackground = false
    
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
    
//    override func preferredStatusBarStyle() -> UIStatusBarStyle {
//        if self.darkBackground == true {
//            // Make the Status Bar White when the Background is Dark
//            return UIStatusBarStyle.LightContent
//        } else {
//            return UIStatusBarStyle.Default
//        }
//    }
//    
    func showChoiceView() {
        // Give the user the choice of uploading or selecting an image
        self.imageChoiceView = ARImageChoiceView(frame: self.view.frame)
        self.imageChoiceView!.registrationViewController = self
        self.view.addSubview(self.imageChoiceView!)
    }
    
    func dismissChoiceView() {
        // Determine if the Choice Subview Needs Dismissal
        if self.imageChoiceView != nil {
            // Animate the new View out of the Viewport
            UIView.animateWithDuration(0.15, animations: {
                () -> Void in
                self.imageChoiceView!.alpha = 0
                }, completion: {
                    (completed: Bool) -> Void in
                    // Remove the Subview
                    self.imageChoiceView!.removeFromSuperview()
            })
            
            // Revert the Status Bar Colour
            self.darkBackground = false
            self.setNeedsStatusBarAppearanceUpdate()
        }
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
        // Set the Image and Dismiss the Picker View
        self.profileImage.image = image
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /* ARImagePickerViewDelegate Methods */
    func userHasChosen() {
        print("User has Chosen")
    }
}
