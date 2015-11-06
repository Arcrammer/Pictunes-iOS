//
//  FeedViewController.swift
//  Ready
//
//  Created by Alexander Rhett Crammer on 10/17/15.
//  Copyright © 2015 HoA. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: Outlets
    @IBOutlet weak var feedView: UITableView!
    
    // MARK: Properties
    var APIKey = "",
    darkBackground = true,
    pictunes: Array<[String: AnyObject]>?,
    pictuneCount = 0
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setNeedsStatusBarAppearanceUpdate()
        
        // Bring a few pictunes from the pictuners the user
        // follows to the application and show them
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
            // The server has sent a response
            print(NSString(data: data!, encoding: NSUTF8StringEncoding)!)
            
            // Try to serialise the JSON and store it in 'self.pictunes'
            do {
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
                print("There was a problem parsing the JSON: ", parseProb)
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
    
    func fetchAPIKey() {
        let keysPlist: NSDictionary?
        if let keysPlistPath = NSBundle.mainBundle().pathForResource("Keys", ofType: "plist") {
            keysPlist = NSDictionary(contentsOfFile: keysPlistPath)
            if let keys = keysPlist {
                self.APIKey = keys["API"] as! String
            }
        }
    }
    
    // MARK: UITableViewDataSource Methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "feedCell")
        if self.pictuneCount > 0 {
            // There are some pictunes to show
            cell.textLabel!.text = String(self.pictunes![indexPath.row]["poster_username"]!)
            return cell
        } else {
            // No pictunes have loaded yet
            cell.textLabel!.text = "No Pictunes Available Yet"
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let amountOfPictunesAvailable = self.pictunes?.count {
            return amountOfPictunesAvailable
        } else {
            return 0
        }
    }
}
