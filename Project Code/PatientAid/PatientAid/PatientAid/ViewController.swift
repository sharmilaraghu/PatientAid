

import UIKit
import Foundation


class ViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var findTextField: UITextField!
    @IBOutlet weak var replaceTextField: UITextField!
    @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
    
    
    
    var activityIndicator:UIActivityIndicatorView!
    var originalTopMargin:CGFloat!
    var Medicine: [PrescribedMeds] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        originalTopMargin = topMarginConstraint.constant
    }
    
    
    
    
    
    @IBAction func setReminders(sender: UIButton) {
        
        
        if textView.text.isEmpty {
            return
        }
 
        var str = textView.text
        
        if let range = str.rangeOfString("Medication")
        {
            var index: Int = distance(str.startIndex, range.startIndex)
            index=index+11
            var myString = str.substringFromIndex(advance(str.startIndex,index))
            
            
            
            
            var prescription: String = myString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let separators = NSCharacterSet(charactersInString: "\n:")
            var list = prescription.componentsSeparatedByCharactersInSet(separators)
          
            for var i = 0; i < list.count; i=i+2 {
                
                var newMed = PrescribedMeds()
                newMed.title = list[i]
                newMed.frequency = list[i+1]
                Medicine.append(newMed)
            }
            
            self.performSegueWithIdentifier("setReminder", sender: Medicine )
        }
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "setReminder")
        {
            
            let data = sender as! [PrescribedMeds]
          
            
            println("Initialized data")
            for med in data{
            println(med.title)
            println(med.frequency)
            
            }
    
            
            let setReminderVC:SetRemindersViewController = segue.destinationViewController as! SetRemindersViewController
            setReminderVC.Medlist = data
            
            
        }
        textView.text=nil
    }
  
    @IBAction func takePhoto(sender: AnyObject) {
        // 1
        view.endEditing(true)
        moveViewDown()
        
        // 2
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo",
            message: nil, preferredStyle: .ActionSheet)
        
        // 3
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let cameraButton = UIAlertAction(title: "Take Photo",
                style: .Default) { (alert) -> Void in
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .Camera
                    self.presentViewController(imagePicker,
                        animated: true,
                        completion: nil)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }

        // 4
        let libraryButton = UIAlertAction(title: "Choose Existing",
            style: .Default) { (alert) -> Void in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .PhotoLibrary
                self.presentViewController(imagePicker,
                    animated: true,
                    completion: nil)
        }
        imagePickerActionSheet.addAction(libraryButton)
        
        // 5
        let cancelButton = UIAlertAction(title: "Cancel",
            style: .Cancel) { (alert) -> Void in
        }
        imagePickerActionSheet.addAction(cancelButton)
        
        // 6
        presentViewController(imagePickerActionSheet, animated: true,
            completion: nil)
    }
    
    func performImageRecognition(image: UIImage) {
        // 1
        let tesseract = G8Tesseract()
        
        // 2
        tesseract.language = "eng"
      
      println("1");
        // 3
        tesseract.engineMode = .TesseractCubeCombined
      println("2");
        // 4
        tesseract.pageSegmentationMode = .Auto
        
        // 5
      println("3");
        tesseract.maximumRecognitionTime = 60.0
        
        // 6
        tesseract.image = image.g8_blackAndWhite()
        tesseract.recognize()
      
      println("4");
        // 7
        textView.text = tesseract.recognizedText
        textView.editable = true
        
        // 8
        removeActivityIndicator()
    }
    
    
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        var scaleFactor: CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    
    
    
    @IBAction func swapText(sender: AnyObject) {
        
        // 1
        if textView.text.isEmpty {
            return
        }
        
        // 2
        textView.text =
            textView.text.stringByReplacingOccurrencesOfString(findTextField.text,
                withString: replaceTextField.text, options: nil, range: nil)
        
        // 3
        findTextField.text = nil
        replaceTextField.text = nil
        
        // 4
        view.endEditing(true)
        moveViewDown()
        
    }
    
    
    // Activity Indicator methods
    
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }
    
    
    func moveViewUp() {
        if topMarginConstraint.constant != originalTopMargin {
            return
        }
        
        topMarginConstraint.constant -= 135
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func moveViewDown() {
        if topMarginConstraint.constant == originalTopMargin {
            return
        }
        
        topMarginConstraint.constant = originalTopMargin
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
    }
    
    @IBAction func backgroundTapped(sender: AnyObject) {
        view.endEditing(true)
        moveViewDown()
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        moveViewUp()
    }
    
    @IBAction func textFieldEndEditing(sender: AnyObject) {
        view.endEditing(true)
        moveViewDown()
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        moveViewDown()
    }
}



extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
            let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
            let scaledImage = scaleImage(selectedPhoto, maxDimension: 1200)
            
            addActivityIndicator()
            
            dismissViewControllerAnimated(true, completion: {
                self.performImageRecognition(scaledImage)
            })
    }
    
}
