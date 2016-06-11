//
//  File.swift
//  UniFeed
//
//  Created by Ranadeep Singh and Arpit Goyal on 09/06/16.
//  Copyright © 2016 Team RaAr. All rights reserved.
//

import Foundation
import UIKit


// APP NAME (Change it accordingly to the name you'll give to this app)
let APP_NAME = "UniFeed"


// YOU CAN CHANGE THE "20" VALUE AS YOU WISH, THAT'S THE MAX. AMOUNT OF EVENTS THE APP WILL QUERY IN THE HOME SCREEN
let limitForRecentEventsQuery = 20


// EMAIL ADDRESS TO EDIT (To get submitted events notifications)
let SUBMISSION_EMAIL_ADDRESS = "submission@unifeed.okli.co"


// EMAIL ADDRESS TO EDIT (where users can directly contact you)
let CONTACT_EMAIL_ADDRESS = "info@unifeed.okli.co"


// EMAIL ADDRESS TO EDIT (where users can report inappropriate contents - accordingly to Apple EULA terms)
let REPORT_EMAIL_ADDRESS = "report@unifeed.okli.co"


// IMPORTANT: REPLACE THE RED STRING BELOW WITH THE UNIT ID YOU'VE GOT BY REGISTERING YOUR APP IN http://www.apps.admob.com
//let ADMOB_UNIT_ID = "ca-app-pub-9733347540588953/7805958028"


// IMPORTANT: REPLACE THE RED STRING BELOW WITH THE APP ID YOU CAN GRAB FROM YOUR OneSignal DASHBOARD -> App Settings
// THIS IS TO ALLOW YOU TO SEND PUSH NOTIFICATIONS TO ALL REGISTERED USERS
let ONESIGNAL_APP_ID = "cf98fac1-1b18-4100-b4f6-d03d9d73af29"



// USEFUL PALETTE OF COLORS
let mainColor = UIColor(red: 63.0/255.0, green: 174.0/255.0, blue: 181.0/255.0, alpha: 1.0)

let red = UIColor(red: 237.0/255.0, green: 85.0/255.0, blue: 100.0/255.0, alpha: 1.0)
let orange = UIColor(red: 250.0/255.0, green: 110.0/255.0, blue: 82.0/255.0, alpha: 1.0)
let yellow = UIColor(red: 255.0/255.0, green: 207.0/255.0, blue: 85.0/255.0, alpha: 1.0)
let lightGreen = UIColor(red: 160.0/255.0, green: 212.0/255.0, blue: 104.0/255.0, alpha: 1.0)
let mint = UIColor(red: 72.0/255.0, green: 207.0/255.0, blue: 174.0/255.0, alpha: 1.0)
let aqua = UIColor(red: 79.0/255.0, green: 192.0/255.0, blue: 232.0/255.0, alpha: 1.0)
let blueJeans = UIColor(red: 93.0/255.0, green: 155.0/255.0, blue: 236.0/255.0, alpha: 1.0)
let lavander = UIColor(red: 172.0/255.0, green: 146.0/255.0, blue: 237.0/255.0, alpha: 1.0)
let darkPurple = UIColor(red: 150.0/255.0, green: 123.0/255.0, blue: 220.0/255.0, alpha: 1.0)
let pink = UIColor(red: 236.0/255.0, green: 136.0/255.0, blue: 192.0/255.0, alpha: 1.0)
let darkRed = UIColor(red: 218.0/255.0, green: 69.0/255.0, blue: 83.0/255.0, alpha: 1.0)
let paleWhite = UIColor(red: 246.0/255.0, green: 247.0/255.0, blue: 251.0/255.0, alpha: 1.0)
let lightGray = UIColor(red: 230.0/255.0, green: 233.0/255.0, blue: 238.0/255.0, alpha: 1.0)
let mediumGray = UIColor(red: 204.0/255.0, green: 208.0/255.0, blue: 217.0/255.0, alpha: 1.0)
let darkGray = UIColor(red: 67.0/255.0, green: 74.0/255.0, blue: 84.0/255.0, alpha: 1.0)
let brownLight = UIColor(red: 198.0/255.0, green: 156.0/255.0, blue: 109.0/255.0, alpha: 1.0)




// HUD VIEW (customizable by editing the code below)
var hudView = UIView()
var animImage = UIImageView(frame: CGRectMake(0, 0, 80, 80))
extension UIViewController {
    func showHUD() {
        hudView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
        hudView.backgroundColor = UIColor.whiteColor()
        hudView.alpha = 0.9
        
        let imagesArr = ["h0", "h1", "h2", "h3", "h4", "h5", "h6", "h7", "h8", "h9"]
        var images : [UIImage] = []
        for i in 0..<imagesArr.count {
            images.append(UIImage(named: imagesArr[i])!)
        }
        animImage.animationImages = images
        animImage.animationDuration = 0.7
        animImage.center = hudView.center
        hudView.addSubview(animImage)
        animImage.startAnimating()
        
        view.addSubview(hudView)
    }
    
    func hideHUD() {  hudView.removeFromSuperview()  }
    
    func simpleAlert(mess:String) {
        UIAlertView(title: APP_NAME, message: mess, delegate: nil, cancelButtonTitle: "OK").show()
    }
}





// PARSE CONFIGURATION ===========================================================
let PARSE_APP_KEY = "v9rNdbkMqMk86xcfmTzbZmf4YX8PpMpFNQT4iiC8"
let PARSE_CLIENT_KEY = "ESHSCOEmpZJQuNLsPIk4SYHhleFk9xjB8z7ii9eq"



/*** DO NOT EDIT THE VARIABLES BELOW ***/

// EVENTS CLASS
var EVENTS_CLASS_NAME = "Events"
var EVENTS_TITLE = "title"
var EVENTS_DESCRIPTION = "description"
var EVENTS_WEBSITE = "website"
var EVENTS_LOCATION = "location"
var EVENTS_START_DATE = "startDate"
var EVENTS_END_DATE = "endDate"
var EVENTS_COST = "cost"
var EVENTS_IMAGE = "image"
var EVENTS_IS_PENDING = "isPending"
var EVENTS_KEYWORDS = "keywords"

// EVENT GALLERY CLASS
var GALLERY_CLASS_NAME = "Gallery"
var GALLERY_EVENT_ID = "eventID"
var GALLERY_IMAGE = "image"


// DATE EXTENSION TO COMPARE DATES
extension NSDate {
    func isGreaterThanDate(dateToCompare : NSDate) -> Bool {
        var isGreater = false
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }
        return isGreater
    }
    
    func isLessThanDate(dateToCompare : NSDate) -> Bool {
        var isLess = false
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        return isLess
    }
    
    func isSameAsDate(dateToCompare : NSDate) -> Bool {
        var isEqualTo = false
        if self.compare(dateToCompare) == NSComparisonResult.OrderedSame {
            isEqualTo = true
        }
        return isEqualTo
    }
    
} // end extension
