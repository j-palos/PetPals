//
//  PopoverTableViewController.swift
//  Code taken from ClassDemo5
//
//  Created by bulko on 2/27/19.
//  Copyright © 2019 bulko. All rights reserved.
//

import UIKit

class PopoverTableViewController<T>: UITableViewController {
    
    typealias SelectionHandler = (T) -> Void
    typealias LabelProvider = (T) -> String
    
    private let values : [T]
    private let labels : LabelProvider
    private let onSelect : SelectionHandler?
    
    init(_ values : [T], labels : @escaping LabelProvider = String.init(describing:), onSelect : SelectionHandler? = nil) {
        self.values = values
        self.onSelect = onSelect
        self.labels = labels
        super.init(style: .plain)
        self.tableView.tableFooterView = UIView()
        self.tableView.frame.size.height = 50
        self.tableView.separatorInset = UIEdgeInsets.zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var cellHeight:CGFloat = CGFloat()
        cellHeight = 50
        return cellHeight
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = labels(values[indexPath.row])
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    
    
}
