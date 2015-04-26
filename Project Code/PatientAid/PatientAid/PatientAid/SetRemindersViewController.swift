

import UIKit
import EventKit

class SetRemindersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  var Medlist: [PrescribedMeds]!
  var appDelegate: AppDelegate?
  var makeEmpty = false
  var events: [EKEventStore]!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      tableView.delegate = self
      tableView.dataSource = self
      tableView.tableFooterView = UIView(frame:CGRectZero)
    }
  
  

    @IBAction func setReminder(sender: UIButton) {
      
      //1
      let eventStore = EKEventStore()
      
      // 2
      switch EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent) {
      case .Authorized:
        insertEvent(eventStore)
      case .Denied:
        println("Access denied")
      case .NotDetermined:
        // 3
        eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion:
          {[weak self] (granted: Bool, error: NSError!) -> Void in
            if granted {
              self!.insertEvent(eventStore)
            } else {
              println("Access denied")
            }
          })
      default:
        println("Case Default")
      }
      
      
      appDelegate = UIApplication.sharedApplication().delegate
        as? AppDelegate
      
      if appDelegate!.eventStore == nil {
        appDelegate!.eventStore = EKEventStore()
        appDelegate!.eventStore!.requestAccessToEntityType(
          EKEntityTypeReminder, completion: {(granted, error) in
            if !granted {
              println("Access to store not granted")
              println(error.localizedDescription)
            } else {
              println("Access granted")
            }
        })
      }
      
      let sharedDefault = NSUserDefaults(suiteName: "group.edu.gatech.iec.patientaid")
        println("SENDING TO WATCH ------>")
      var count = 0;
      for med in Medlist{
      let cur:String = med.title+" "+med.frequency
        let key = "shared"+String(count)
        sharedDefault?.setObject(cur, forKey: key)
        count = count + 1
      }
      
      sharedDefault?.setInteger(count, forKey: "count")
          sharedDefault?.synchronize()
    
      if (appDelegate!.eventStore != nil) {
        self.createReminder()
        
        makeEmpty = true
        //Launches the reminders app ?
        
        var reminderUrl:NSString = "x-apple-reminder://";
        
        let url = NSURL(string:reminderUrl as String)!
        UIApplication.sharedApplication().openURL(url)
      }
    
    }
  
  func createReminder() {
   
    var count = 0
    for med in Medlist{
      count++
    }
    
    for var i = 0; i < count; i++ {
      
      if let range = Medlist[i].frequency.rangeOfString("*")
      {
          var index: Int = distance(Medlist[i].frequency.startIndex, range.startIndex)
  
        
          var temp: Int = index - 1

          var myTemp = Medlist[i].frequency.substringToIndex(advance(Medlist[i].frequency.startIndex,temp))
          myTemp = myTemp.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
          let separators = NSCharacterSet(charactersInString: "-")
        var list = myTemp.componentsSeparatedByCharactersInSet(separators)
        
        index=index+1
        var myString = Medlist[i].frequency.substringFromIndex(advance(Medlist[i].frequency.startIndex,index))
        myString = myString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        myString = myString.substringToIndex(advance(myString.endIndex, -4))
        myString = myString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        var freq = (myString as NSString).doubleValue;
   
        for var k=0; k<list.count; k++ {
          
          if(list[k].toInt()==1){
            
            let reminder = EKReminder(eventStore: appDelegate!.eventStore)
            let n:Double = 60 * 60 * 24 * freq;
            
            let interval:NSTimeInterval = n;
            let endDate:NSDate = NSDate().dateByAddingTimeInterval(interval);
            
            let recurrence = EKRecurrenceEnd.recurrenceEndWithEndDate(endDate) as! EKRecurrenceEnd
           
            let recurrenceRule = EKRecurrenceRule(recurrenceWithFrequency: EKRecurrenceFrequencyDaily, interval: 1, end: recurrence)
            
            reminder.addRecurrenceRule(recurrenceRule)
            reminder.title = Medlist[i].title
            reminder.calendar =
              appDelegate!.eventStore!.defaultCalendarForNewReminders()
        
        var tomorrow:NSDate = NSDate().dateByAddingTimeInterval(60*60*24);
        
        var gregorian:NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!;
        
        var unit : NSCalendarUnit = (NSCalendarUnit.YearCalendarUnit|NSCalendarUnit.MonthCalendarUnit|NSCalendarUnit.DayCalendarUnit|NSCalendarUnit.HourCalendarUnit|NSCalendarUnit.MinuteCalendarUnit);
        var comps:NSDateComponents = gregorian.components(unit, fromDate: tomorrow);
            reminder.startDateComponents = comps
            reminder.dueDateComponents = comps
            
        if(k==0)
        {
          println("Entered 0 for "+Medlist[i].title)
          comps.setValue(7, forComponent: NSCalendarUnit.HourCalendarUnit);
          comps.setValue(0, forComponent: NSCalendarUnit.MinuteCalendarUnit);
        }
        else if (k==1)
        {
          println("Entered 1 for "+Medlist[i].title)
          comps.setValue(14, forComponent: NSCalendarUnit.HourCalendarUnit);
          comps.setValue(0, forComponent: NSCalendarUnit.MinuteCalendarUnit);
        }
        else
        {
          println("Entered 2 for "+Medlist[i].title)
          comps.setValue(19, forComponent: NSCalendarUnit.HourCalendarUnit);
          comps.setValue(0, forComponent: NSCalendarUnit.MinuteCalendarUnit);
        }
        var alarmSet : NSDate = gregorian.dateFromComponents(comps)!;
        
        
        let alarm = EKAlarm(absoluteDate: alarmSet)
        
        reminder.addAlarm(alarm)
            
            var error: NSError?
            appDelegate!.eventStore!.saveReminder(reminder,
              commit: true, error: &error)
            
            if error != nil {
              println("Reminder failed with error \(error?.localizedDescription)")
            }
          }
        }
        
      }
    }
  }
  
  
  
  func insertEvent(store: EKEventStore) {

    var count = 0
    for med in Medlist{
      count++
    }

    for var i = 0; i < count; i++ {
      
      if let range = Medlist[i].frequency.rangeOfString("*")
      {
        var index: Int = distance(Medlist[i].frequency.startIndex, range.startIndex)
        
        
        var temp: Int = index - 1
        
        var myTemp = Medlist[i].frequency.substringToIndex(advance(Medlist[i].frequency.startIndex,temp))
        myTemp = myTemp.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        let separators = NSCharacterSet(charactersInString: "-")
        var list = myTemp.componentsSeparatedByCharactersInSet(separators)
        
        index=index+1
        var myString = Medlist[i].frequency.substringFromIndex(advance(Medlist[i].frequency.startIndex,index))
        myString = myString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        myString = myString.substringToIndex(advance(myString.endIndex, -4))
        myString = myString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        var freq = (myString as NSString).doubleValue;
        var calendars = store.calendarsForEntityType(EKEntityTypeEvent)
          as! [EKCalendar]
        let icloudSource = sourceInEventStore(store,
          type: EKSourceTypeCalDAV,
          title: "iCloud")
        
        if icloudSource != nil{
          println("You have not configured iCloud for your device.")
          //return
          let icalendar = calendarWithTitle("Medications",
            type: EKCalendarTypeCalDAV,
            source: icloudSource!,
            eventType: EKEntityTypeEvent)
             calendars.append(icalendar!)
        }
              for calendar in calendars {

                  if calendar.title == "Medications" {
                    
                    for var k=0; k < list.count; k++ {
                      
                      if(list[k].toInt()==1){
                        var startDate = NSDate()
                        var tomorrow:NSDate = NSDate().dateByAddingTimeInterval(60*60*24);
                        let n:Double = 60 * 60 * 24 * freq;
        
                        let interval:NSTimeInterval = n;
                        var endDate = tomorrow.dateByAddingTimeInterval(interval);
        
                        let recurrence = EKRecurrenceEnd.recurrenceEndWithEndDate(endDate) as! EKRecurrenceEnd
        
                        let recurrenceRule = EKRecurrenceRule(recurrenceWithFrequency: EKRecurrenceFrequencyDaily, interval: 1, end: recurrence)
        
                        var event = EKEvent(eventStore: store)
                        event.calendar = calendar
        
                        event.title = Medlist[i].title
            
                        event.addRecurrenceRule(recurrenceRule)
        
                        var gregorian:NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!;

        
                        var unit:NSCalendarUnit = (NSCalendarUnit.YearCalendarUnit|NSCalendarUnit.MonthCalendarUnit|NSCalendarUnit.DayCalendarUnit|NSCalendarUnit.HourCalendarUnit|NSCalendarUnit.MinuteCalendarUnit);
                        var comps:NSDateComponents = gregorian.components(unit, fromDate: tomorrow)
                    
                       
        
                        if(k==0)
                        {let calendarN = NSCalendar.currentCalendar()
                          let date = NSDate()
                          
                          comps.hour = 7
                          comps.minute = 0
                        
                          event.startDate = calendarN.dateFromComponents(comps)!
                          event.endDate = calendarN.dateFromComponents(comps)!
                          
                        }
                        else if (k==1)
                        {
                      
                          let calendarN = NSCalendar.currentCalendar()
                          let date = NSDate()
                          comps.hour = 14
                          comps.minute = 0
                          event.startDate = calendarN.dateFromComponents(comps)!
                          event.endDate = calendarN.dateFromComponents(comps)!
                         
                        }
                        else
                        {
                          let calendarN = NSCalendar.currentCalendar()
                          let date = NSDate()
                          comps.hour = 19
                          comps.minute = 0
                          event.startDate = calendarN.dateFromComponents(comps)!
                          event.endDate = calendarN.dateFromComponents(comps)!
                        }
        
        
                      var alarmSet : NSDate = gregorian.dateFromComponents(comps)!;
        
        
                      let alarm = EKAlarm(absoluteDate: alarmSet)
        
                      event.addAlarm(alarm)
        // 5
        // Save Event in Calendar
                      var error: NSError?
                      let result = store.saveEvent(event, span: EKSpanThisEvent, error: &error)
        
                    if result == false {
                        if let theError = error {
                            println("An error occured \(theError)")
                            }
                    }
            }
          }
        }
      }
    }
  }
    
}
  
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func sourceInEventStore(
    eventStore: EKEventStore,
    type: EKSourceType,
    title: String) -> EKSource?{
      
      for source in eventStore.sources() as! [EKSource]{
        if source.sourceType.value == type.value &&
          source.title.caseInsensitiveCompare(title) ==
          NSComparisonResult.OrderedSame{
            return source
        }
      }
      
      return nil
  }
  
  func calendarWithTitle(
    title: String,
    type: EKCalendarType,
    source: EKSource,
    eventType: EKEntityType) -> EKCalendar?{
      
      for calendar in source.calendarsForEntityType(eventType) as! Set<EKCalendar>{
        if calendar.title.caseInsensitiveCompare(title) ==
          NSComparisonResult.OrderedSame &&
          calendar.type.value == type.value{
            return calendar
        }
      }
      
      return nil
  }
  
    
    
    @IBOutlet weak var tableView: UITableView!
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
   
    println("Count")
    return Medlist.count
    
  }
  
  
  func tableView(tableView: UITableView!,
    cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
  {
    let cell:UITableViewCell = UITableViewCell(style:UITableViewCellStyle.Subtitle, reuseIdentifier:"cell")
    cell.backgroundColor = UIColor.clearColor()
    cell.textLabel?.text = Medlist[indexPath.row].title
    cell.textLabel?.font = UIFont(name: "Cochin-Bold", size: 18)
    cell.textLabel?.textColor = UIColor(red: 50.0/255.0, green: 79.0/255.0, blue: 133.0/255.0, alpha: 1.0)
    cell.detailTextLabel?.text = Medlist[indexPath.row].frequency
    cell.detailTextLabel?.font = UIFont(name: "Cochin-Italic", size: 15)
    cell.detailTextLabel?.textColor = UIColor(red: 50.0/255.0, green: 79.0/255.0, blue: 133.0/255.0, alpha: 1.0)
  
    
    return cell
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
}

