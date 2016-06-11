//
//  File.swift
//  UniFeed
//
//  Created by Ranadeep Singh and Arpit Goyal on 09/06/16.
//  Copyright © 2016 Team RaAr. All rights reserved.
//

import UIKit
import Parse
import EventKit
import MapKit
import MessageUI
import Social
import GoogleMobileAds
import AudioToolbox


class EventDetails: UIViewController,
MKMapViewDelegate,
MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate,
GADBannerViewDelegate
{

    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var eventImage: UIImageView!
    @IBOutlet var descrTxt: UITextView!
    
    @IBOutlet var detailsView: UIView!
    @IBOutlet var addToCalOutlet: UIButton!
    @IBOutlet var shareOnFBOutlet: UIButton!
    @IBOutlet var shareOnTWOutlet: UIButton!
    @IBOutlet weak var shareByMailOutlet: UIButton!
    @IBOutlet weak var shareBySMSOutlet: UIButton!
    
    @IBOutlet var dayNrLabel: UILabel!
    @IBOutlet var monthLabel: UILabel!
    @IBOutlet var yearLabel: UILabel!
    @IBOutlet var registerOutlet: UIButton!
    
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var endDateLabel: UILabel!
    @IBOutlet var costLabel: UILabel!
    @IBOutlet var websiteLabel: UILabel!
    
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var mapView: MKMapView!
    
    var backButt = UIButton()
    var reportButt = UIButton()
    
    //Ad banners properties
    //var adMobBannerView = GADBannerView()
    
    
    
    
    /* Variables */
    var eventObj = PFObject(className: EVENTS_CLASS_NAME)
    var galleryArray = NSMutableArray()
    
    var socialController = SLComposeViewController()
    
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinView:MKPinAnnotationView!
    var region: MKCoordinateRegion!

    
    
    
    
    

// MARK: - VIEW DID LOAD
override func viewDidLoad() {
        super.viewDidLoad()
    
    // Back BarButton Item
    backButt = UIButton(type: UIButtonType.Custom)
    backButt.frame = CGRectMake(0, 0, 44, 44)
    backButt.setBackgroundImage(UIImage(named: "backButt"), forState: UIControlState.Normal)
    backButt.addTarget(self, action: #selector(backButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButt)
    
    // Report Event BarButton Item
    reportButt = UIButton(type: UIButtonType.Custom)
    reportButt.frame = CGRectMake(0, 0, 44, 44)
    reportButt.setBackgroundImage(UIImage(named: "reportButt"), forState: UIControlState.Normal)
    reportButt.addTarget(self, action: #selector(reportButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reportButt)
    
    
    // Round views corners
    addToCalOutlet.layer.cornerRadius = 5
    
    shareOnFBOutlet.layer.cornerRadius = 5
    shareOnTWOutlet.layer.cornerRadius = 5
    shareByMailOutlet.layer.cornerRadius = 5
    shareBySMSOutlet.layer.cornerRadius = 5
    
    registerOutlet.layer.cornerRadius = 5
    registerOutlet.layer.borderColor = mainColor.CGColor
    registerOutlet.layer.borderWidth = 1.5

    
    // Init ad banners
    //initAdMobBanner()
    
    
    
    // GET EVENT'S TITLE
    self.title = "\(eventObj[EVENTS_TITLE]!)"
    
    // GET EVENT'S IMAGE
    let imageFile = eventObj[EVENTS_IMAGE] as? PFFile
    imageFile?.getDataInBackgroundWithBlock { (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                self.eventImage.image = UIImage(data:imageData)
    } } }
    
    
    // GET EVENT'S DECSRIPTION
    descrTxt.text = "\(eventObj[EVENTS_DESCRIPTION]!)"
    descrTxt.sizeToFit()
    
    
    // GET EVENT'S START DATE (for the labels on the left side of the event's image)
    let dayFormatter = NSDateFormatter()
    dayFormatter.dateFormat = "dd"
    let dayStr = dayFormatter.stringFromDate(eventObj[EVENTS_START_DATE] as! NSDate)
    dayNrLabel.text = dayStr
    
    let monthFormatter = NSDateFormatter()
    monthFormatter.dateFormat = "MMM"
    let monthStr = monthFormatter.stringFromDate(eventObj[EVENTS_START_DATE] as! NSDate)
    monthLabel.text = monthStr
    
    let yearFormatter = NSDateFormatter()
    yearFormatter.dateFormat = "yyyy"
    let yearStr = yearFormatter.stringFromDate(eventObj[EVENTS_START_DATE] as! NSDate)
    yearLabel.text = yearStr
    
    
    // GET EVENT START AND END DATES & TIME
    let startDateFormatter = NSDateFormatter()
    startDateFormatter.dateFormat = "MMM dd @hh:mm a"
    let startDateStr = startDateFormatter.stringFromDate(eventObj[EVENTS_START_DATE] as! NSDate).uppercaseString
    let endDateFormatter = NSDateFormatter()
    endDateFormatter.dateFormat = "MMM dd @hh:mm a"
    let endDateStr = endDateFormatter.stringFromDate(eventObj[EVENTS_END_DATE] as! NSDate).uppercaseString
    
    startDateLabel.text = "Start Date: \(startDateStr)"
    if endDateStr != "" {  endDateLabel.text = "End Date: \(endDateStr)"
    } else { endDateLabel.text = ""  }
    
    
    // DISABLE THE ADD TO CALENDAR BUTTON IN CASE THE EVENT HAS PASSED
    let currentDate = NSDate()
    if currentDate.isGreaterThanDate(eventObj[EVENTS_END_DATE] as! NSDate) {
        addToCalOutlet.enabled = false
        addToCalOutlet.backgroundColor = mediumGray
        addToCalOutlet.setTitle("This event has passed", forState: UIControlState.Normal)
        
        registerOutlet.enabled = false
        registerOutlet.backgroundColor = mediumGray
        registerOutlet.setTitle("EVENT PASSED", forState: UIControlState.Normal)
    }
    
    
    // GET EVENT'S COST
    costLabel.text = "Cost: \(eventObj[EVENTS_COST]!)".uppercaseString
    
    // GET EVENT'S WEBSITE
    if eventObj[EVENTS_WEBSITE] != nil {
    websiteLabel.text = "Website: \(eventObj[EVENTS_WEBSITE]!)"
    } else {  websiteLabel.text = ""  }
    
    // GET EVENT'S LOCATION
    locationLabel.text = "\(eventObj[EVENTS_LOCATION]!)".uppercaseString
    addPinOnMap(locationLabel.text!.lowercaseString)
    
    
    // Move the addToCalendar button below the descriptionTxt
    detailsView.frame.origin.y = descrTxt.frame.origin.y + descrTxt.frame.size.height + 10
    
    // Finally Resize the conainer ScrollView
    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, detailsView.frame.origin.y + detailsView.frame.size.height)
    
}
    
    
    

    
// MARK: - ADD A PIN ON THE MAPVIEW
func addPinOnMap(address: String) {
    mapView.delegate = self
    
        if mapView.annotations.count != 0 {
            annotation = mapView.annotations[0] 
            mapView.removeAnnotation(annotation)
        }
    
        // Make a search on the Map
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = address
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            // Add PointAnnonation text and a Pin to the Map
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = "\(self.eventObj[EVENTS_TITLE]!)".uppercaseString
            self.pointAnnotation.coordinate = CLLocationCoordinate2D( latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:localSearchResponse!.boundingRegion.center.longitude)
            
            self.pinView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinView.annotation!)
            
            // Zoom the Map to the location
            self.region = MKCoordinateRegionMakeWithDistance(self.pointAnnotation.coordinate, 1000, 1000);
            self.mapView.setRegion(self.region, animated: true)
            self.mapView.regionThatFits(self.region)
            self.mapView.reloadInputViews()
        }
}

// MARK: - CUSTOMIZE PIN ANNOTATION
func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKPointAnnotation) {
            let reuseID = "CustomPinAnnotationView"
            var annotView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
            if annotView == nil {
                annotView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
                annotView!.canShowCallout = true
                
                // Custom Pin image
                let imageView = UIImageView(frame: CGRectMake(0, 0, 44, 44))
                imageView.image =  UIImage(named: "locIcon")
                imageView.center = annotView!.center
                imageView.contentMode = UIViewContentMode.ScaleAspectFill
                annotView!.addSubview(imageView)
                
                // Add a RIGHT Callout Accessory
                let rightButton = UIButton(type: UIButtonType.Custom)
                rightButton.frame = CGRectMake(0, 0, 32, 32)
                rightButton.layer.cornerRadius = rightButton.bounds.size.width/2
                rightButton.clipsToBounds = true
                rightButton.setImage(UIImage(named: "openInMaps"), forState: UIControlState.Normal)
                annotView!.rightCalloutAccessoryView = rightButton
            }
            return annotView
        }
    
return nil
}
    
    
// MARK: -  OPEN THE NATIVE iOS MAPS APP
func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        annotation = view.annotation
        let coordinate = annotation.coordinate
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapitem = MKMapItem(placemark: placemark)
        mapitem.name = annotation.title!
        mapitem.openInMapsWithLaunchOptions(nil)
}

    
    
    
    
    
// MARK: - ADD EVENT TO IOS CALENDAR
@IBAction func addToCalButt(sender: AnyObject) {
    let eventStore = EKEventStore()
    
    switch EKEventStore.authorizationStatusForEntityType(EKEntityType.Event) {
    case .Authorized: insertEvent(eventStore)
    case .Denied: print("Access denied")
    case .NotDetermined:
        
    eventStore.requestAccessToEntityType(.Event, completion: { (granted, error) -> Void in
        if granted { self.insertEvent(eventStore)
        } else { print("Access denied")  }
    })
        
    default: print("Case Default")
    }
}
    
func insertEvent(store: EKEventStore) {
    let calendars = store.calendarsForEntityType(EKEntityType.Event) 
        
      for calendar in calendars {
            
            if calendar.title == "Calendar" {
                // Get Start and End dates
                let startDate = eventObj[EVENTS_START_DATE] as! NSDate
                let endDate = eventObj[EVENTS_END_DATE] as! NSDate
                
                // Create Event
                let event = EKEvent(eventStore: store)
                event.calendar = calendar
                event.title = "\(eventObj[EVENTS_TITLE]!)"
                event.startDate = startDate
                event.endDate = endDate
                
                // Save Event in Calendar
                var error: NSError?
                let result: Bool
                do {
                    try store.saveEvent(event, span: EKSpan.ThisEvent)
                    result = true
                } catch let error1 as NSError {
                    error = error1
                    result = false
                }
                
                simpleAlert("This Event has been added to your iOS Calendar")
                
                if result == false {
                    if let theError = error {
                        print("ERROR: \(theError)")
                    }
                }
                
            }
    
    }
}
    
    
    
    
 
// MARK: - SHARE EVENT ON FACEBOOK
@IBAction func shareOnFBButt(sender: AnyObject) {
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
        socialController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        socialController.setInitialText("Check out this Event: \(eventObj[EVENTS_TITLE]!) on #\(APP_NAME)")
        socialController.addImage(eventImage.image)
        self.presentViewController(socialController, animated: true, completion: nil)
    } else {
        let alert = UIAlertView(title: "Facebook", message: "Please login to your Facebook account in Settings", delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }
    
    socialController.completionHandler = { result -> Void in
        var output = ""
        switch result {
            case SLComposeViewControllerResult.Cancelled: output = "Sharing cancelled"
            case SLComposeViewControllerResult.Done: output = "Your image is on Facebook!"
        }
        self.simpleAlert(output)
    }
    
}
    
    
// MARK: - SHARE EVENT ON TWITTER
@IBAction func shareOnTWButt(sender: AnyObject) {
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
        socialController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        socialController.setInitialText("Check out this Event: \(eventObj[EVENTS_TITLE]!) on #\(APP_NAME)")
        socialController.addImage(eventImage.image)
        self.presentViewController(socialController, animated: true, completion: nil)
    } else {
        let alert = UIAlertView(title: "Twitter", message: "Please login to your Twitter account in Settings", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    socialController.completionHandler = { result -> Void in
        var output = ""
        switch result {
            case SLComposeViewControllerResult.Cancelled: output = "Sharing cancelled"
            case SLComposeViewControllerResult.Done: output = "Your image is on Twitter!"
        }
        
        self.simpleAlert(output)
    }
}

    
    
    

// MARK: - SHARE EVEN BY MAIL
@IBAction func shareByMailButt(sender: AnyObject) {
    let mailComposer = MFMailComposeViewController()
    mailComposer.mailComposeDelegate = self
    mailComposer.setSubject("Check out this Event!")
    mailComposer.setMessageBody("\(eventObj[EVENTS_TITLE]!) on #\(APP_NAME)", isHTML: true)
    
    // Attach an image
    let imageData = UIImageJPEGRepresentation(eventImage.image!, 1.0)
    mailComposer.addAttachmentData(imageData!, mimeType: "image/png", fileName: "event.jpg")
    
    if MFMailComposeViewController.canSendMail() {
        presentViewController(mailComposer, animated: true, completion: nil)
        
    } else { simpleAlert("Your device cannot send emails. Please configure an email address into Settings -> Mail, Contacts, Calendars.") }

}
    
    
    
    
    
// MARK: - SHARE EVENT BY SMS
@IBAction func shareBySMSButt(sender: AnyObject) {
    
    let messageComposer = MFMessageComposeViewController()
    messageComposer.messageComposeDelegate = self
    messageComposer.body = "Check out this Event: '\(eventObj[EVENTS_TITLE]!)' on #\(APP_NAME)"

    
    // Check if the device can send attachments
    if MFMessageComposeViewController.respondsToSelector(#selector(MFMessageComposeViewController.canSendAttachments)) &&
        MFMessageComposeViewController.canSendAttachments() {
            let attachmentData: NSData = UIImageJPEGRepresentation(eventImage.image!, 1.0)!
            messageComposer.addAttachmentData(attachmentData, typeIdentifier: "kUTTypeMessage", filename: "event.jpg")
            presentViewController(messageComposer, animated: true, completion: nil)
            
    // Device can send only Text messages
    } else if MFMessageComposeViewController.canSendText()  &&  !MFMessageComposeViewController.canSendAttachments() {
        presentViewController(messageComposer, animated: true, completion: nil)

        
    // Device cannot send messages
    } else { simpleAlert("Sorry, your device doesn't support Messages") }

    
    
}
// Message Delegate
func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
     dismissViewControllerAnimated(true, completion: nil)
}
    
    
    
    
    
// MARK: - OPEN LINK TO WEBSITE BUTTON
@IBAction func openLinkButt(sender: AnyObject) {
    let webURL = NSURL(string: "\(eventObj[EVENTS_WEBSITE]!)")
    UIApplication.sharedApplication().openURL(webURL!)
}
    
    
// MARK: - REGISTER TO THE EVENT'S WEBSITE BUTTON
@IBAction func registerButt(sender: AnyObject) {
    let webURL = NSURL(string: "\(eventObj[EVENTS_WEBSITE]!)")
    UIApplication.sharedApplication().openURL(webURL!)
}
    
    
    
// MARK: - REPORT INAPPROPRIATE CONTENTS BUTTON
func reportButton(sender: UIButton) {
    
    // This string containes standard HTML tags, you can edit them as you wish
    let messageStr = "<font size = '1' color= '#222222' style = 'font-family: 'HelveticaNeue'>Hello,<br>Please check the following Event since it seems it contains inappropriate/offensive contents:<br><br>Event Title: <strong>\(eventObj[EVENTS_TITLE]!)</strong><br>Event ID: <strong>\(eventObj.objectId!)</strong><br><br>Thanks,<br>Regards.</font>"
    
    let mailComposer = MFMailComposeViewController()
    mailComposer.mailComposeDelegate = self
    mailComposer.setSubject("Reporting inappropriate contents on an Event")
    mailComposer.setMessageBody(messageStr, isHTML: true)
    mailComposer.setToRecipients([REPORT_EMAIL_ADDRESS])
    
    if MFMailComposeViewController.canSendMail() {
        presentViewController(mailComposer, animated: true, completion: nil)
    } else {
        simpleAlert("Your device cannot send emails. Please configure an email address into Settings -> Mail, Contacts, Calendars.")
    }
}
// Email delegate
func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError?) {
        
        var resultMess = ""
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            resultMess = "Mail cancelled"
        case MFMailComposeResultSaved.rawValue:
            resultMess = "Mail saved"
        case MFMailComposeResultSent.rawValue:
            resultMess = "Mail sent!"
        case MFMailComposeResultFailed.rawValue:
            resultMess = "Something went wrong with sending Mail, try again later."
        default:break
        }
        
        simpleAlert(resultMess)
        dismissViewControllerAnimated(false, completion: nil)
}
    

        
        
// MARK: - BACK BUTTON
func backButton(sender: UIButton) {
    navigationController?.popViewControllerAnimated(true)
}

    
 
    
    
    
    
    
    
// MARK: - ADMOB BANNER METHODS
/*
func initAdMobBanner() {
        adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSizeMake(320, 50))
        adMobBannerView.frame = CGRectMake(0, self.view.frame.size.height, 320, 50)
        adMobBannerView.adUnitID = ADMOB_UNIT_ID
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        view.addSubview(adMobBannerView)
        let request = GADRequest()
        adMobBannerView.loadRequest(request)
}
    
    
    // Hide the banner
    func hideBanner(banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        banner.frame = CGRectMake(view.frame.size.width/2 - banner.frame.size.width/2, view.frame.size.height, banner.frame.size.width, banner.frame.size.height)
        UIView.commitAnimations()
        banner.hidden = true
    }
    
    // Show the banner
    func showBanner(banner: UIView) {
        UIView.beginAnimations("showBanner", context: nil)
        banner.frame = CGRectMake(view.frame.size.width/2 - banner.frame.size.width/2,
                                  view.frame.size.height - banner.frame.size.height - 44,
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
*/  
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
