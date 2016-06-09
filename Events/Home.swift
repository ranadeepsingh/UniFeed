//
//  File.swift
//  UniFeed
//
//  Created by Ranadeep Singh on 09/06/16.
//  Copyright © 2016 Team RaAr. All rights reserved.
//

import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox


class Home: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UITextFieldDelegate,
GADBannerViewDelegate
{

    /* Views */
    @IBOutlet var eventsCollView: UICollectionView!
    
    @IBOutlet var searchView: UIView!
    @IBOutlet var searchTxt: UITextField!
    @IBOutlet var searchCityTxt: UITextField!
    
    @IBOutlet weak var searchOutlet: UIBarButtonItem!
    
    //Ad banners properties
    var adMobBannerView = GADBannerView()
    
    
    
    /* Variables */
    var eventsArray = NSMutableArray()
    var cellSize = CGSize()
    var searchViewIsVisible = false
    

    
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    // PREDEFINED SIZE OF THE EVENT CELLS
    if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
        // iPhone
        cellSize = CGSizeMake(view.frame.size.width-30, 270)
    } else  {
        // iPad
        cellSize = CGSizeMake(350, 270)
    }

    
    // Init ad banners
    initAdMobBanner()
    
    
    // Associate the device with a user for Push Notifications
    let installation = PFInstallation.currentInstallation()
    installation.addUniqueObject("Events", forKey: "channels")
    installation.saveInBackground()
    
    
    
    // Search View initial setup
    searchView.frame.origin.y = -searchView.frame.size.height
    searchView.layer.cornerRadius = 10
    searchViewIsVisible = false
    searchTxt.resignFirstResponder()
    searchCityTxt.resignFirstResponder()
    
    // Set placeholder's color and text for Search text fields
    searchTxt.attributedPlaceholder = NSAttributedString(string: "Type an event name (or leave it blank)", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()] )
    searchCityTxt.attributedPlaceholder = NSAttributedString(string: "Type a city/town name (or leave it blank)", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()] )
    
    
    // Call a Parse query
    queryLatestEvents()
}

    
    
// MARK: - QUERY LATEST EVENTS
func queryLatestEvents() {
    showHUD()
    eventsArray.removeAllObjects()
    
    let query = PFQuery(className: EVENTS_CLASS_NAME)
    query.whereKey(EVENTS_IS_PENDING, equalTo: false)
    query.orderByDescending(EVENTS_START_DATE)
    query.limit = limitForRecentEventsQuery
    // Query bloxk
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            if let objects = objects  {
                for object in objects {
                    self.eventsArray.addObject(object)
            }}
            // Reload CollView
            self.eventsCollView.reloadData()
            self.hideHUD()
            
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
    
}
    
    
    
    

// MARK: -  COLLECTION VIEW DELEGATES
func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
}

func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return eventsArray.count
}

func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EventCell", forIndexPath: indexPath) as! EventCell
    
    var eventsClass = PFObject(className: EVENTS_CLASS_NAME)
    eventsClass = eventsArray[indexPath.row] as! PFObject
    
    
    // GET EVENT'S IMAGE
    let imageFile = eventsClass[EVENTS_IMAGE] as? PFFile
    imageFile?.getDataInBackgroundWithBlock { (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                cell.eventImage.image = UIImage(data:imageData)
    } } }
    
    
    // GET EVENT'S START DATE (for the labels on the left side of the event's image)
    let dayFormatter = NSDateFormatter()
    dayFormatter.dateFormat = "dd"
    let dayStr = dayFormatter.stringFromDate(eventsClass[EVENTS_START_DATE] as! NSDate)
    cell.dayNrLabel.text = dayStr
    
    let monthFormatter = NSDateFormatter()
    monthFormatter.dateFormat = "MMM"
    let monthStr = monthFormatter.stringFromDate(eventsClass[EVENTS_START_DATE] as! NSDate)
    cell.monthLabel.text = monthStr
    
    let yearFormatter = NSDateFormatter()
    yearFormatter.dateFormat = "yyyy"
    let yearStr = yearFormatter.stringFromDate(eventsClass[EVENTS_START_DATE] as! NSDate)
    cell.yearLabel.text = yearStr
    
    
    // GET EVENT'S TITLE
    cell.titleLbl.text = "\(eventsClass[EVENTS_TITLE]!)".uppercaseString
    
    // GET EVENT'S LOCATION
    cell.locationLabel.text = "\(eventsClass[EVENTS_LOCATION]!)".uppercaseString
    
    
    // GET EVENT START AND END DATES & TIME
    let startDateFormatter = NSDateFormatter()
    startDateFormatter.dateFormat = "MMM dd @hh:mm a"
    let startDateStr = startDateFormatter.stringFromDate(eventsClass[EVENTS_START_DATE] as! NSDate).uppercaseString
    
    let endDateFormatter = NSDateFormatter()
    endDateFormatter.dateFormat = "MMM dd @hh:mm a"
    let endDateStr = endDateFormatter.stringFromDate(eventsClass[EVENTS_END_DATE] as! NSDate).uppercaseString
    
    if startDateStr == endDateStr {  cell.timeLabel.text = startDateStr
    } else {  cell.timeLabel.text = "\(startDateStr) - \(endDateStr)"
    }
    
    // GET EVENT'S COST
    cell.costLabel.text = "\(eventsClass[EVENTS_COST]!)".uppercaseString

    
return cell
}

func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return cellSize
}

    
// MARK: - TAP A CELL TO OPEN EVENT DETAILS CONTROLLER
func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    var eventsClass = PFObject(className: EVENTS_CLASS_NAME)
    eventsClass = eventsArray[indexPath.row] as! PFObject
    hideSearchView()
    
    let edVC = storyboard?.instantiateViewControllerWithIdentifier("EventDetails") as! EventDetails
    edVC.eventObj = eventsClass
    navigationController?.pushViewController(edVC, animated: true)
}
   

    
    
    

// MARK: - SEARCH EVENTS BUTTON
@IBAction func searchButt(sender: AnyObject) {
    searchViewIsVisible = !searchViewIsVisible
    
    if searchViewIsVisible { showSearchView()
    } else { hideSearchView()  }
    
}
    
    
// MARK: - TEXTFIELD DELEGATE (tap Search on the keyboard to launch a search query) */
func textFieldShouldReturn(textField: UITextField) -> Bool {
    hideSearchView()
    showHUD()
    
    // Make a new Parse query
    eventsArray.removeAllObjects()
    let keywordsArray = searchTxt.text!.componentsSeparatedByString(" ") as [String]
    // print("\(keywordsArray)")
    
    let query = PFQuery(className: EVENTS_CLASS_NAME)
    if searchTxt.text != ""   { query.whereKey(EVENTS_KEYWORDS, containsString: "\(keywordsArray[0])".lowercaseString) }
    if searchCityTxt.text != "" { query.whereKey(EVENTS_KEYWORDS, containsString: searchCityTxt.text!.lowercaseString) }
    query.whereKey(EVENTS_IS_PENDING, equalTo: false)
    
    
    // Query block
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            if let objects = objects  {
                for object in objects {
                    self.eventsArray.addObject(object)
            } }
            
            // EVENT FOUND
            if self.eventsArray.count > 0 {
                self.eventsCollView.reloadData()
                self.title = "Events Found"
                self.hideHUD()
            
            // EVENT NOT FOUND
            } else {
                self.simpleAlert("No results. Please try a different search")
                self.hideHUD()
                
                self.queryLatestEvents()
            }
            
        // error found
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    } }


return true
}

    
    
    
// MARK: - SHOW/HIDE SEARCH VIEW
func showSearchView() {
    searchTxt.becomeFirstResponder()
    searchTxt.text = "";  searchCityTxt.text = ""
    
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
        self.searchView.frame.origin.y = 32
    }, completion: { (finished: Bool) in })
}
func hideSearchView() {
    searchTxt.resignFirstResponder(); searchCityTxt.resignFirstResponder()
    searchViewIsVisible = false
    
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
        self.searchView.frame.origin.y = -self.searchView.frame.size.height
    }, completion: { (finished: Bool) in })
}
    
    
    
// MARK: -  REFRESH  BUTTON
@IBAction func refreshButt(sender: AnyObject) {
    queryLatestEvents()
    searchTxt.resignFirstResponder();  searchCityTxt.becomeFirstResponder()
    hideSearchView()
    searchViewIsVisible = false
    
    self.title = "Recent Events"
}
    
    

    
    
    
    
// MARK: -  ADMOB BANNER METHODS

    // Initialize Google AdMob banner
    func initAdMobBanner() {
        adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSizeMake(320, 50))
        adMobBannerView.frame = CGRectMake(0, self.view.frame.size.height, 320, 50)
        adMobBannerView.adUnitID = ADMOB_UNIT_ID
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        // adMobBannerView.hidden = true
        view.addSubview(adMobBannerView)
        
        let request = GADRequest()
        adMobBannerView.loadRequest(request)
    }
    
    
    // Hide the banner
    func hideBanner(banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        // Hide the banner moving it below the bottom of the screen
        banner.frame = CGRectMake(0, self.view.frame.size.height, banner.frame.size.width, banner.frame.size.height)
        UIView.commitAnimations()
        banner.hidden = true
        
    }
    
    // Show the banner
    func showBanner(banner: UIView) {
        UIView.beginAnimations("showBanner", context: nil)
        
        // Move the banner on the bottom of the screen
        banner.frame = CGRectMake(view.frame.size.width/2 - banner.frame.size.width/2, view.frame.size.height - banner.frame.size.height - 44,
            banner.frame.size.width, banner.frame.size.height);
        
        UIView.commitAnimations()
        banner.hidden = false
        
    }
    
    
    // AdMob banner available
    func adViewDidReceiveAd(view: GADBannerView!) {
        print("AdMob loaded!")
        showBanner(adMobBannerView)
    }
    
    // NO AdMob banner available
    func adView(view: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("AdMob Can't load ads right now, they'll be available later \n\(error)")
        hideBanner(adMobBannerView)
    }
    

    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
