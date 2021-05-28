//
//  PurchasedHistoryTableViewController.swift
//  Market
//
//  Created by Conor Andrews on 07/05/2021.
//  Copyright © 2021 Conor Andrews. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift
import NVActivityIndicatorView

class PurchasedHistoryTableViewController: UITableViewController {

    //MARK: - Vars
    var itemArray : [Item] = []
    var order: Order?
    
    var activityIndicator: NVActivityIndicatorView?
    
    //MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
    
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60, height: 60), type: .ballPulse, color: #colorLiteral(red: 0.2425246239, green: 0.5274564624, blue: 0.9168085456, alpha: 1), padding: nil)
        
        if order != nil {
            loadItems()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        
        cell.generateCell(itemArray[indexPath.row])

        return cell
    }
    
    //MARK: - Load items
    private func loadItems() {
        
        downloadOrderItems(order!.orderItems) { (allItems) in
            self.itemArray = allItems
            print("This order has \(allItems.count) purchased items")
            self.tableView.reloadData()
        }
    }
}

extension PurchasedHistoryTableViewController: EmptyDataSetSource, EmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        return NSAttributedString(string: "No items to display!")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "emptyData")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Please check back later")
    }
}

