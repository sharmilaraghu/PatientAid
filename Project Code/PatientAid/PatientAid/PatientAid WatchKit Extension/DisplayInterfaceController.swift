
import WatchKit
import Foundation


class DisplayInterfaceController: WKInterfaceController {

    @IBOutlet weak var Label1: WKInterfaceLabel!
  
    @IBOutlet weak var Label2: WKInterfaceLabel!
    
    @IBOutlet weak var Label3: WKInterfaceLabel!
    
    @IBOutlet weak var Label4: WKInterfaceLabel!
  
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
  
  

    
    @IBAction func buttonPressed(){
    let sharedDefault = NSUserDefaults(suiteName: "group.edu.gatech.iec.patientaid")
    
    sharedDefault?.synchronize()
    
    let count = sharedDefault?.integerForKey("count")
    if(count == 3)
    {
      let ourString1 = sharedDefault?.objectForKey("shared0") as! String
      Label1.setText(ourString1)
      let ourString2 = sharedDefault?.objectForKey("shared1") as! String
      Label2.setText(ourString2)
      let ourString3 = sharedDefault?.objectForKey("shared2") as! String
      Label3.setText(ourString3)
      
      
    }
    else
    {
      let ourString1 = sharedDefault?.objectForKey("shared0") as! String
      Label1.setText(ourString1)
      let ourString2 = sharedDefault?.objectForKey("shared1") as! String
      Label2.setText(ourString2)
      let ourString3 = sharedDefault?.objectForKey("shared2") as! String
      Label3.setText(ourString3)
      let ourString4 = sharedDefault?.objectForKey("shared3") as! String
      Label4.setText(ourString4)
    
      }
    
    
    
 
  }

}
