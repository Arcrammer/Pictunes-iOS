//
//  FeedViewController.swift
//  Ready
//
//  Created by Alexander Rhett Crammer on 10/17/15.
//  Copyright © 2015 HoA. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    /* Outlets */
    @IBOutlet weak var feedView: UITableView!
    
    /* Properties */
    var darkBackground = true
    var pictunes: Array<[String: AnyObject]>?
    var pictuneCount = 0
    
    /* Methods */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.fetchPictunes()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if self.darkBackground == true {
            // Make the Status Bar White when the Background is Dark
            return UIStatusBarStyle.LightContent
        } else {
            return UIStatusBarStyle.Default
        }
    }
    
    func fetchPictunes() -> Bool {
        // Get some pictunes
        var morePictunesRetrieved = false
        let prePictuneCount = self.pictuneCount
        let request = NSMutableURLRequest(URL: NSURL(string: "http://api.pictunes.dev/")!)
        request.addValue("ff40ea8422f3687f57b3e345272f7dfd4de575f4", forHTTPHeaderField: "X-Authorization")
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            print(NSString(data: data!, encoding: NSUTF8StringEncoding)!)
            // The request for pictunes has completed
            do {
                // Try to serialise the JSON and store it
                if let newPictunes = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? Array<[String: AnyObject]> {
                    if self.pictuneCount == 0 {
                        // Create the new pictunes
                        self.pictunes = newPictunes
                        self.pictuneCount = self.pictunes!.count
                    } else {
                        // Append the new pictunes
                        self.pictunes? += newPictunes
                    }
                }
            } catch let parseProb {
                print(parseProb)
            }
            // Reload the feedView if more pictunes have loaded
            if prePictuneCount < self.pictuneCount {
                dispatch_async(dispatch_get_main_queue(), {
                    () -> Void in
                    // Reload the table view on the main thread
                    self.feedView.reloadData()
                })
                morePictunesRetrieved = true
            }
        }).resume()
        return morePictunesRetrieved
    }
    
    /* UITableViewDataSource Methods */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "feedCell")
        cell.textLabel!.text = String(self.pictunes![indexPath.row]["post_creator"]!)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pictuneCount
    }
}
