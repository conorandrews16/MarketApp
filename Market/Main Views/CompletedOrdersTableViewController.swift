//
//  CompletedOrdersTableViewController.swift
//  Market
//
//  Created by Conor Andrews on 07/05/2021.
//  Copyright © 2021 Conor Andrews. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class CompletedOrdersTableViewController: UITableViewController {

    //MARK: - Vars
    var user: MUser?
    var itemArray: [Item]?
    var orderArray: [Order] = []
    
    //MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
    
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if MUser.currentUser() != nil {
            loadOrders()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return orderArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! OrderTableViewCell
        
        cell.generateCell(orderArray[indexPath.row])

        return cell
    }
    
    //MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        showOrderView(orderArray[indexPath.row])
    }
    
    private func showOrderView(_ order: Order) {
        
        let orderVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "purchasedItemView") as! PurchasedHistoryTableViewController
        
        orderVC.order = order
        
        self.navigationController?.pushViewController(orderVC, animated: true)
    }
    
    //MARK: - Load orders
    private func loadOrders() {
        
        downloadOrdersFromFirebase(MUser.currentId()) { (allOrders) in
            self.orderArray = allOrders
            print("We have \(allOrders.count) completed orders")
            self.tableView.reloadData()
        }
    }
}

extension CompletedOrdersTableViewController: EmptyDataSetSource, EmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        return NSAttributedString(string: "No orders to display!")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "emptyData")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Please check back later")
    }
}

