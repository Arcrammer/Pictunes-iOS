//
//  FeedViewController.swift
//  Ready
//
//  Created by Alexander Rhett Crammer on 10/17/15.
//  Copyright © 2015 HoA. All rights reserved.
//

import UIKit

enum APIError: ErrorType {
    case APIKeyMissingOrInvalid
}

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: Outlets
    @IBOutlet weak var feedView: UITableView!
    
    // MARK: Properties
    var APIKey = "",
    darkBackground = true,
    pictunes: Array<[String: AnyObject]>?,
    pictunerImages: Array<UIImage> = [],
    pictuneImages: Array<UIImage> = [],
    pictuneCount = 0
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setNeedsStatusBarAppearanceUpdate()
        
        // Make the bounce area dark gray
        let feedTableViewBackground = UIView(frame: self.feedView.frame)
        feedTableViewBackground.backgroundColor = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1)
        self.feedView.backgroundView = feedTableViewBackground
        
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
                    
                    // Make sure the JSON doesnt say GEN-Unauthorised in that one key
                    
                    if self.pictuneCount == 0 {
                        // Create the new pictunes
                        self.pictunes = newPictunes
                        self.pictuneCount = self.pictunes!.count
                    } else {
                        // Append the new pictunes
                        self.pictunes? += newPictunes
                    }
                } else {
                    // There wasn't Pictune data in the
                    // response. The most likely case is
                    // that the developer either has an
                    // old API key or is missing it in
                    // 'Keys.plist'. Go to the server
                    // and look at the 'api_keys' table
                    // if you're missing it, then set it
                    // here in 'Keys.plist'
                    throw APIError.APIKeyMissingOrInvalid
                }
            } catch let prob {
                print("There was a problem connecting to the API:", prob)
            }
            
            // Fetch the images for each pictune
            if self.pictuneCount > 0 {
                var index = 0
                for var pictune in self.pictunes! {
                    // Add a number to each of the pictunes
                    pictune["index"] = index
                    index++
                    
                    // Get the pictuner image
                    let pictunerImageRequest = NSMutableURLRequest(URL: NSURL(string: "http://api.pictunes.dev/pictuner/selfie/\(index)")!)
                    pictunerImageRequest.setValue(self.APIKey, forHTTPHeaderField: "X-Authorization")
                    NSURLSession.sharedSession().dataTaskWithRequest(pictunerImageRequest, completionHandler: {
                        (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                        
                        // Add the pictuner image
                        if let imageData = data {
                            if let image = UIImage(data: imageData) {
                                self.pictunerImages.append(image)
                            } else {
                                self.pictunerImages.append(UIImage(named: "Logo")!)
                            }
                        } else {
                            self.pictunerImages.append(UIImage(named: "Logo")!)
                        }
                    }).resume()
                    
                    // Get the pictune image
                    let pictuneImageRequest = NSMutableURLRequest(URL: NSURL(string: "http://api.pictunes.dev/pictune/image/\(index)")!)
                    pictuneImageRequest.setValue(self.APIKey, forHTTPHeaderField: "X-Authorization")
                    NSURLSession.sharedSession().dataTaskWithRequest(pictuneImageRequest, completionHandler: {
                        (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                        
                        // Add the pictune image
                        self.pictuneImages.append(UIImage(data: data!)!)
                        
                        // Reload the feed view now that we have the images
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
            // There are some pictunes to show; Create and update the posts
            if self.pictuneImages.count > indexPath.row {
                
                // We have an image for the user who made the current pictune
                if let pictunerImageView = cell.contentView.viewWithTag(2) as? UIImageView {
                    pictunerImageView.layer.cornerRadius = 17.5 // Cut it to a circle
                    pictunerImageView.layer.masksToBounds = true
                    pictunerImageView.image = self.pictunerImages[0]
                }
                
                // We also have an image for the pictune at the current post
                if let pictuneImageView = cell.contentView.viewWithTag(1) as? UIImageView {
                    pictuneImageView.image = self.pictuneImages[indexPath.row]
                    
                }
            }
            return cell
        } else {
            // No pictunes have loaded yet; We probably need more time
            // to load the image and audio assets for some of them
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
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 280.0
    }
}
