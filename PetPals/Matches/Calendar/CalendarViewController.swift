//
//  CalendarViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 3/20/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!

    let formatter = DateFormatter()
    
    var eventsFromTheServer: [String:String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        DispatchQueue.global().asyncAfter(deadline: .now()) {
            let serverObjects = self.getServerEvents()
            for (date, event) in serverObjects {
                let stringDate = self.formatter.string(from: date)
                self.eventsFromTheServer[stringDate] = event
            }
            
            DispatchQueue.main.async {
                self.calendarView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureCell(cell: JTAppleCell?, cellState: CellState) {
        guard let myCustomCell = cell as? CalendarCell else { return }
        formatter.dateFormat = "yyyy MM dd"
        
        handleCellEvents(cell: myCustomCell, cellState: cellState)
    }
    
    func handleCellEvents(cell: CalendarCell, cellState: CellState) {
        cell.eventDotView.isHidden = !eventsFromTheServer.contains { $0.key == formatter.string(from: cellState.date) }
    }
    
}


extension CalendarViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2019 03 01")!
        let endDate = formatter.date(from: "2019 12 31")!
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCell
        configureCell(cell: cell, cellState: cellState)
        cell.dateLabel.text = cellState.text
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCell
        cell.dateLabel.text = cellState.text
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        formatter.dateFormat = "MMMM"
        month.text = formatter.string(from: date)
    }
    
}

extension CalendarViewController {
    func getServerEvents() -> [Date:String] {
        formatter.dateFormat = "yyyy MM dd"
        
        return [
            formatter.date(from: "2019 03 02")!: "Date with Emily",
            formatter.date(from: "2019 03 11")!: "Date with Jeffery",
            formatter.date(from: "2019 03 20")!: "Date with Leo"
        ]
    }
}


