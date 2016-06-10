//
//  File.swift
//  UniFeed
//
//  Created by Ranadeep Singh on 09/06/16.
//  Copyright © 2016 Team RaAr. All rights reserved.
//

import UIKit
import Parse
import MessageUI


class SubmitEvent: UIViewController,
UITextFieldDelegate,
UITextViewDelegate,
MFMailComposeViewControllerDelegate,
UIAlertViewDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
{

    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    
    @IBOutlet var nameTxt: UITextField!
    @IBOutlet var descriptionTxt: UITextView!
    @IBOutlet var locationTxt: UITextField!
    @IBOutlet var costTxt: UITextField!
    @IBOutlet var websiteTxt: UITextField!
    @IBOutlet var eventImage: UIImageView!
    @IBOutlet var yourNameTxt: UITextField!
    @IBOutlet var yourEmailTxt: UITextField!
    
    @IBOutlet var startDateOutlet: UIButton!
    @IBOutlet var endDateOutlet: UIButton!
    
    @IBOutlet var datePicker: UIDatePicker!
    
    @IBOutlet var submitEventOutlet: UIButton!
    var clearFieldsButt = UIButton()
    
    
    /* Variables */
    var startDateSelected = false
    var startDate = NSDate()
    var endDate = NSDate()
    
    
    
    
// MARK: - VIEW DID LOAD
override func viewDidLoad() {
        super.viewDidLoad()

    // Setup container ScrollView
    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, submitEventOutlet.frame.origin.y + 250)
    
    // Setup datePicker
    datePicker.frame.origin.y = view.frame.size.height
    datePicker.addTarget(self, action: #selector(dateChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
    datePicker.backgroundColor = UIColor.whiteColor()
    startDateSelected = false
    
    
    // Clear fields BarButton Item
    clearFieldsButt = UIButton(type: UIButtonType.Custom)
    clearFieldsButt.frame = CGRectMake(0, 0, 78, 36)
    clearFieldsButt.setTitle("Clear fields", forState: UIControlState.Normal)
    clearFieldsButt.setTitleColor(mainColor, forState: UIControlState.Normal)
    clearFieldsButt.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 13)
    clearFieldsButt.backgroundColor = UIColor.whiteColor()
    clearFieldsButt.layer.cornerRadius = 5
    clearFieldsButt.addTarget(self, action: #selector(clearFields(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: clearFieldsButt)
    
    
    // Round views corners
    submitEventOutlet.layer.cornerRadius = 5
}
    

// MARK: - CLEAR ALL TEXTS AND IMAGE (In order for you to insert a new Event)
func clearFields(sender:UIButton) {
    nameTxt.text = ""
    descriptionTxt.text = ""
    locationTxt.text = ""
    startDateOutlet.setTitle("Tap to choose date", forState: UIControlState.Normal)
    endDateOutlet.setTitle("Tap to choose date", forState: UIControlState.Normal)
    costTxt.text = ""
    websiteTxt.text = "http://"
    yourNameTxt.text = ""
    yourEmailTxt.text = ""
    eventImage.image = nil
    
    dismissKeyboard()
}

    
    
    
// MARK: - START DATE PICKER CHANGED VALUE
func dateChanged(datePicker: UIDatePicker) {
    // Get current date
    let currentDate = NSDate()
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MMM dd yyyy @hh:mm a"
    let dateStr = dateFormatter.stringFromDate(datePicker.date)
    
    // SET START DATE
        if startDateSelected {
            if datePicker.date.isLessThanDate(currentDate) {
                let alert = UIAlertView(title: APP_NAME,
                    message: "Start date cannot be less than today",
                    delegate: nil,
                    cancelButtonTitle: "OK")
                alert.show()
            } else {
                startDateOutlet.setTitle(dateStr, forState: UIControlState.Normal)
                startDate = datePicker.date
            }
            
            
        // SET END DATE
        } else {
            if datePicker.date.isSameAsDate(currentDate)   ||
               datePicker.date.isLessThanDate(currentDate) {
                let alert = UIAlertView(title: APP_NAME,
                    message: "End date cannot be equal or less than today",
                    delegate: nil,
                    cancelButtonTitle: "OK")
                alert.show()
            } else {
                endDateOutlet.setTitle(dateStr, forState: UIControlState.Normal)
                endDate = datePicker.date
            }
        }
        
}
    
    
    
// MARK: - SHOW/HIDE DATE PICKERS
func showDatePicker() {
    dismissKeyboard()
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.datePicker.frame.origin.y = self.view.frame.size.height - self.datePicker.frame.size.height - 44
    }, completion: { (finished: Bool) in  })
}
func hideDatePicker() {
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.datePicker.frame.origin.y = self.view.frame.size.height
    }, completion: { (finished: Bool) in  })
}
    

    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func TapToDismissKeyboard(sender: UITapGestureRecognizer) {
        dismissKeyboard()
        hideDatePicker()
}
    
// DISMISS KEYBOARD
func dismissKeyboard() {
    nameTxt.resignFirstResponder()
    descriptionTxt.resignFirstResponder()
    locationTxt.resignFirstResponder()
    costTxt.resignFirstResponder()
    websiteTxt.resignFirstResponder()
    yourNameTxt.resignFirstResponder()
    yourEmailTxt.resignFirstResponder()
}

    
// MARK: - TEXTFIELD DELEGATES
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == nameTxt { descriptionTxt.becomeFirstResponder()  }
    if textField == locationTxt { locationTxt.resignFirstResponder()  }
    if textField == costTxt { websiteTxt.becomeFirstResponder()  }
    if textField == websiteTxt { websiteTxt.resignFirstResponder()  }
    if textField == yourNameTxt { yourEmailTxt.becomeFirstResponder()  }
    if textField == yourEmailTxt { yourEmailTxt.resignFirstResponder()  }
    
return true
}
    
func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    if textField == nameTxt { hideDatePicker() }
    if textField == locationTxt { hideDatePicker() }
    if textField == descriptionTxt { hideDatePicker() }
    if textField == costTxt { hideDatePicker() }
    if textField == yourNameTxt { hideDatePicker() }
    if textField == yourEmailTxt { hideDatePicker() }
    
return true
}
    
    
// MARK: - CHOOSE IMAGE BUTTON
@IBAction func chooseImageButt(sender: AnyObject) {
    let alert = UIAlertView(title: APP_NAME,
    message: "Select Source",
    delegate: self,
    cancelButtonTitle: "Cancel",
    otherButtonTitles: "Photo Library", "Camera")
    alert.show()
}
// AlertView delegate
func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    if alertView.buttonTitleAtIndex(buttonIndex) == "Photo Library" {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
                imagePicker.allowsEditing = false
                dismissKeyboard()
                presentViewController(imagePicker, animated: true, completion: nil)
        }
            
    } else if alertView.buttonTitleAtIndex(buttonIndex) == "Camera" {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
                imagePicker.allowsEditing = false
                dismissKeyboard()
                presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
        
}
func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        eventImage.image = image
        dismissViewControllerAnimated(true, completion: nil)
}

    
    
// MARK: - SET START DATE BUTTON
@IBAction func startDateButt(sender: AnyObject) {
    startDateSelected = true
    showDatePicker()
    layoutButtons()
}

    
// MARK: - SET END DATE BUTTON
@IBAction func endDateButt(sender: AnyObject) {
    startDateSelected = false
    showDatePicker()
    layoutButtons()
}

// MARK: - CHANGE BUTTONS BORDER
func layoutButtons() {
    if startDateSelected {
        startDateOutlet.layer.borderColor = mainColor.CGColor
        startDateOutlet.layer.borderWidth = 2
        endDateOutlet.layer.borderWidth = 0
    } else {
        endDateOutlet.layer.borderColor = mainColor.CGColor
        endDateOutlet.layer.borderWidth = 2
        startDateOutlet.layer.borderWidth = 0
    }
}
    
    
    
    
// MARK: - SUBMIT EVENT BUTTON
@IBAction func submitEventButt(sender: AnyObject) {
    showHUD()
    dismissKeyboard()
    
    // Save event on Parse
    let eventsClass = PFObject(className: EVENTS_CLASS_NAME)
    eventsClass[EVENTS_TITLE] = nameTxt.text
    eventsClass[EVENTS_DESCRIPTION] = descriptionTxt.text
    eventsClass[EVENTS_LOCATION] = locationTxt.text
    eventsClass[EVENTS_COST] = costTxt.text
    eventsClass[EVENTS_WEBSITE] = websiteTxt.text
    eventsClass[EVENTS_IS_PENDING] = true
    eventsClass[EVENTS_KEYWORDS] = "\(nameTxt!.text!.lowercaseString) \(locationTxt!.text!.lowercaseString) \(descriptionTxt!.text.lowercaseString)"
    eventsClass[EVENTS_START_DATE] = startDate
    eventsClass[EVENTS_END_DATE] = endDate
    
    // Save Image (if exists)
    if eventImage.image != nil {
        let imageData = UIImageJPEGRepresentation(eventImage.image!, 0.5)
        let imageFile = PFFile(name:"image.jpg", data:imageData!)
        eventsClass[EVENTS_IMAGE] = imageFile
    
    
    eventsClass.saveInBackgroundWithBlock { (success, error) -> Void in
        if error == nil {
            self.hideHUD()
            self.openMailVC()
            
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
        
     
        
    // AN EVENT NEEDS A COVER IMAGE!
    } else {
        self.simpleAlert("You must attach an image to this Event!")
        self.hideHUD()
    }

}
    
    
// MARK: -  OPEN MAIL CONTROLLER
func openMailVC() {
    // This string containes standard HTML tags, you can edit them as you wish
    let messageStr = "<font size = '1' color= '#222222' style = 'font-family: 'HelveticaNeue'>Event Title:<strong>\(nameTxt!.text!)</strong><br>Description: <strong>\(descriptionTxt.text)</strong><br>Location: <strong>\(locationTxt!.text!)</strong><br>Start Date: <strong>\(startDateOutlet.titleLabel!.text!)</strong><br>End Date: <strong>\(endDateOutlet.titleLabel!.text!)</strong><br>Cost: <strong>\(costTxt!.text!)</strong><br>Website: <strong>\(websiteTxt!.text!)</strong><br><br>Email for reply: <strong>\(yourEmailTxt!.text!)</strong><br>Regards.</font>"
    
    
    let mailComposer = MFMailComposeViewController()
    mailComposer.mailComposeDelegate = self
    mailComposer.setSubject("Event Submission from \(yourNameTxt!.text!)")
    mailComposer.setMessageBody(messageStr, isHTML: true)
    mailComposer.setToRecipients([SUBMISSION_EMAIL_ADDRESS])
    // Attach the event image
    if eventImage.image != nil {
        let imageData = UIImageJPEGRepresentation(eventImage.image!, 1.0)
        mailComposer.addAttachmentData(imageData!, mimeType: "image/jpg", fileName: "\(nameTxt.text).jpg")
    }
    
    if MFMailComposeViewController.canSendMail() { presentViewController(mailComposer, animated: true, completion: nil)
    } else {
        let alert = UIAlertView(title: APP_NAME,
        message: "Your device cannot send emails. Please configure an email address into Settings -> Mail, Contacts, Calendars.",
        delegate: nil,
        cancelButtonTitle: "OK")
        alert.show()
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
            resultMess = "Thanks for submitting your Event!\nWe'll review it asap and email you when your Event will be published or in case we'll need some additional info from you"
        case MFMailComposeResultFailed.rawValue:
            resultMess = "Something went wrong with sending Mail, try again later."
        default:break
        }
        
        // Show email result alert
        let alert = UIAlertView(title: APP_NAME,
        message: resultMess,
        delegate: self,
        cancelButtonTitle: "OK" )
        alert.show()
        
        dismissViewControllerAnimated(false, completion: nil)
}
    
    
    
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
