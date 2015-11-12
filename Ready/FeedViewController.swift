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
    pictuneImages: Array<UIImage> = [],
    pictuneCount = 0,
    pictuneCells: Array<UITableViewCell> = []
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setNeedsStatusBarAppearanceUpdate()
        
        // Get the API key
        self.fetchAPIKey()
        
        // Bring a few pictunes from the pictuners the user
        // follows to the application and show them
//        TODO: if userLoggedIn {
            self.fetchPictunes()
//        } else {
//            self.navigationController!.popToRootViewControllerAnimated(true)
//        }
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
        request.addValue(self.APIKey, forHTTPHeaderField: "X-Authorization")
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            // The server has sent a response; Try to serialise
            // the JSON and store it in 'self.pictunes'
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
            
            // Fetch the images for each pictune
            if self.pictuneCount > 0 {
                var index = 0
                for var pictune in self.pictunes! {
                    // Add a number to each of the pictunes
                    pictune["index"] = index
                    index++
                    
                    // Get the image
                    let pictuneImageRequest = NSMutableURLRequest(URL: NSURL(string: "http://api.pictunes.dev/pictune/image/\(index)")!)
                    pictuneImageRequest.setValue(self.APIKey, forHTTPHeaderField: "X-Authorization")
                    NSURLSession.sharedSession().dataTaskWithRequest(pictuneImageRequest, completionHandler: {
                        (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                        
                        // Add the pictune image
                        self.pictuneImages.append(UIImage(data: data!)!)
                        
                        // Reload the feed view now that we have the image
                        dispatch_async(dispatch_get_main_queue(), {
                            self.feedView.reloadData()
                        })
                    }).resume()
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
                
                // Reload the feedView if more pictunes have loaded
                if prePictuneCount < self.pictuneCount {
                    dispatch_async(dispatch_get_main_queue(), {
                        () -> Void in
                        
                        // Reload the table view on the main thread
                        self.feedView.reloadData()
                    })
                    morePictunesRetrieved = true
                }
            }
        }).resume()
        self.feedView.reloadData()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("feedCell")!
        
        if self.pictunes?.count > 0 {
            // There are some pictunes to show; Create and update the image
            if self.pictuneImages.count > indexPath.row {
//                let pictuneImage = self.pictuneImages[indexPath.row]
                
                // We have an image for the pictune at the current post
                if let imageView = cell.contentView.viewWithTag(1) as? UIImageView {
                    imageView.image = UIImage(named: "CasCornelissen")
                    
                }
            }
            self.pictuneCells.append(cell)
            return cell
        } else {
            // No pictunes have loaded yet; We probably need more time
            // to load the image and audio assets for some of them
            cell.textLabel!.text = "No Pictunes Available Yet"
            self.pictuneCells.append(cell)
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
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 280.0
    }
}
