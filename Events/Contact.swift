//
//  File.swift
//  UniFeed
//
//  Created by Ranadeep Singh and Arpit Goyal on 09/06/16.
//  Copyright © 2016 Team RaAr. All rights reserved.
//

import UIKit
import MessageUI


class Contact: UIViewController,
MFMailComposeViewControllerDelegate,
UITextFieldDelegate
{

    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var fullNameTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var messageTxt: UITextView!
    
    @IBOutlet var sendOutlet: UIButton!
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    // Setup container ScrollView
    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, sendOutlet.frame.origin.y + 250)
    
    // Round views corners
    sendOutlet.layer.cornerRadius = 5
    
}
    
    
    
// MARK - TEXTFIELDS DELEGATE
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == fullNameTxt  { emailTxt.becomeFirstResponder()  }
    if textField == emailTxt  { messageTxt.becomeFirstResponder()  }

return true
}
    
    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func tapToDismissKeyboard(sender: UITapGestureRecognizer) {
    dismissKeyboard()
}

func dismissKeyboard() {
    fullNameTxt.resignFirstResponder()
    emailTxt.resignFirstResponder()
    messageTxt.resignFirstResponder()
}
    
    
// MARK: - SEND MESSAGE BUTTON
@IBAction func sendMessageButt(sender: AnyObject) {
    dismissKeyboard()
    
    // This string containes standard HTML tags, you can edit them as you wish
    let messageStr = "<font size = '1' color= '#222222' style = 'font-family: 'HelveticaNeue'>\(messageTxt.text)<br><br>You can reply to: \(emailTxt!.text!)</font>"
    
    let mailComposer = MFMailComposeViewController()
    mailComposer.mailComposeDelegate = self
    mailComposer.setSubject("Message from \(fullNameTxt!.text!)")
    mailComposer.setMessageBody(messageStr, isHTML: true)
    mailComposer.setToRecipients([CONTACT_EMAIL_ADDRESS])
    
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
            resultMess = "Thanks for contacting us!\nWe'll get back to you asap."
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
