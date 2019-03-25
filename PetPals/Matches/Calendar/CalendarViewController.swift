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
        formatter.dateFormat = "yyyy MM dd"
        
        // Decide if dot is hidden or not
        handleCellEvents(cell: myCustomCell, cellState: cellState)
    }
    
    // Function to hide or show dot depending on if event will occur
    func handleCellEvents(cell: CalendarCell, cellState: CellState) {
        cell.eventDotView.isHidden = !datesGiven.contains { $0.key == formatter.string(from: cellState.date) }
    }
    
}

extension CalendarViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    // Create the calendar
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        // Set way want to format date
        formatter.dateFormat = "yyyy MM dd"
        
        // Set standards
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        // Set start & end for the calendar
        let startDate = formatter.date(from: "2019 03 01")!
        let endDate = formatter.date(from: "2019 12 31")!
        
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
        formatter.dateFormat = "yyyy MM dd"
        
        // Return hardcoded data for now
        return [
            formatter.date(from: "2019 03 02")!: "Date with Emily",
            formatter.date(from: "2019 03 11")!: "Date with Jeffery",
            formatter.date(from: "2019 03 20")!: "Date with Leo"
        ]
    }
}

