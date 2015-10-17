//
//  ForgottenPasswordViewController.swift
//  Ready
//
//  Created by Alexander Rhett Crammer on 10/17/15.
//  Copyright © 2015 HoA. All rights reserved.
//

import UIKit

class ForgottenPasswordViewController: UIViewController {
    /* Actions */
    @IBAction func dismissView() {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func sendResetLink(sender: AnyObject) {
        let successNotification = UIAlertController(title: "Sent!", message:  "Check your inbox for an email that will allow you to reset your password.", preferredStyle: UIAlertControllerStyle.Alert)
        successNotification.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel, handler: {
        (action: UIAlertAction) -> Void in
            self.navigationController!.popViewControllerAnimated(true)
        }))
        self.presentViewController(successNotification, animated: true, completion: nil)
    }
    
    /* Methods */
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}
