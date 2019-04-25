//
//  CalendarViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 3/20/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit
import JTAppleCalendar

// Much of the code in this file was taken from & adapted from JTAppleCalendar
class CalendarViewController: UIViewController {
    
    // Connect necessary fields
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    // Simple formatter to use for dates
    let formatter = DateFormatter()
    
    // List of the current dates
    var datesGiven: [String:String] = [:]
    
    // Variable to connect to Overall Matches VC
    var parentVC: OverallMatchesViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Find the dates given, and show a dot on those dates
        DispatchQueue.global().asyncAfter(deadline: .now()) {
            let dateObjects = self.getDates()
            for (date, event) in dateObjects {
                let stringDate = self.formatter.string(from: date)
                self.datesGiven[stringDate] = event
            }
            
            DispatchQueue.main.async {
                self.calendarView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Necessary for cell
    func configureCell(cell: JTAppleCell?, cellState: CellState) {
        // Get cell
        guard let myCustomCell = cell as? CalendarCell else { return }
        
        // Set way want to format date
        formatter.dateFormat = "MM/dd/yyyy"
        
        // Decide if dot is hidden or not
        handleCellEvents(cell: myCustomCell, cellState: cellState)
    }
    
    // Function to hide or show dot depending on if event will occur
    func handleCellEvents(cell: CalendarCell, cellState: CellState) {
        cell.eventDotView.isHidden = !datesGiven.contains { $0.key == formatter.string(from: cellState.date) }
    }
    
    // Function to display popup of dates for the user on the day selected
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        // Set way want to format date
        formatter.dateFormat = "MM/dd/yyyy"
        
        // Get this day
        let chosenDay = formatter.string(from: date)
        
        // Find the dates on this day
        // In hard code is just one string, but will be list in future
        if let dayDatesString = datesGiven[chosenDay] {
            let dayDates = [dayDatesString]
            
            // Control heigh of popover; Only want to show 4 max at a time
            var popoverHeight = 50
            if dayDates.count <= 4 {
                popoverHeight = popoverHeight * dayDates.count
            } else {
                popoverHeight = 200
            }
            
            // Create the table view
            let controller = PopoverTableViewController(dayDates)
            controller.preferredContentSize = CGSize(width: 300, height: popoverHeight)
            
            // Create the popover and present it
            let presentationController = AlwaysPresentAsPopover.configurePresentation(forController: controller)
            presentationController.sourceView = cell
            presentationController.sourceRect = cell!.bounds
            presentationController.permittedArrowDirections = [.up]
            self.present(controller, animated: true)
        }
    }
    
    // If left arrow clicked, go to previous month
    @IBAction func leftArrowClicked(_ sender: Any) {
        let currDate = calendarView.visibleDates().monthDates.first!.date
        let nextDate = Calendar.current.date(byAdding: .month, value: -1, to: currDate)!
        calendarView.scrollToDate(nextDate)
    }
    
    // If the user clicks the right arrow, send the calendar ahead by a month
    @IBAction func rightArrowClicked(_ sender: Any) {
        let currDate = calendarView.visibleDates().monthDates.first!.date
        let nextDate = Calendar.current.date(byAdding: .month, value: 1, to: currDate)!
        calendarView.scrollToDate(nextDate)
    }
    
}

extension CalendarViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    // Create the calendar
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        // Set way want to format date
        formatter.dateFormat = "MM/dd/yyyy"
        
        // Set standards
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        // Set start & end for the calendar
        let startDate = formatter.date(from: "04/01/2019")!
        let endDate = formatter.date(from: "04/30/2020")!
        
        // Send in information to be configured for calendar
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }
    
    // Decide what is at each cell (date)
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        // Grab this cell
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCell
        
        // Design this cell with given state
        configureCell(cell: cell, cellState: cellState)
        cell.dateLabel.text = cellState.text
        
        return cell
    }
    
    // Design the cell
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        // Grab this cell
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCell
        
        // Update the text for this cell
        cell.dateLabel.text = cellState.text
    }
    
    // Update text for Month based on month have scrolled to
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        // Find out which month is currently visible
        let date = visibleDates.monthDates.first!.date
        
        // Set way want to format month text
        formatter.dateFormat = "MMMM"
        
        // Display the month that has been scrolled to
        month.text = formatter.string(from: date)
    }
    
}

extension CalendarViewController {
    
    // Grab dates that are set for this user
    func getDates() -> [Date:String] {
        // Set way want to format date
        formatter.dateFormat = "MM/dd/yyyy"
        
        // Return hardcoded data for now
        return [
            formatter.date(from: "04/02/2019")!: "Date with Emily at 12pm",
            formatter.date(from: "04/11/2019")!: "Date with Jeffery at 12pm",
            formatter.date(from: "04/20/2019")!: "Date with Leo at 12pm"
        ]
    }
}

