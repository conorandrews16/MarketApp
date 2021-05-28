//
//  ItemsTableViewController.swift
//  Market
//
//  Created by Conor Andrews on 07/05/2021.
//  Copyright © 2021 Conor Andrews. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class ItemsTableViewController: UITableViewController {

    //MARK: Vars
    var category: Category?

    var itemArray: [Item] = []

    var rightBarButtonItem: UIBarButtonItem!
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        self.title = category?.name
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
//        hidePlusButtonForCustomers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if category != nil {
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

    //MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(itemArray[indexPath.row])
    }

    // MARK: Hide plus button
    private func hidePlusButtonForCustomers() {
        if MUser.currentUser() != nil {
            self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "itemToAddItemSeg" {
            
            let vc = segue.destination as! AddItemViewController
            vc.category = category!
        }
    }
    
    private func showItemView(_ item: Item) {
        
        let itemVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "itemView") as! ItemViewController
        
        itemVC.item = item
        
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
    
    //MARK: - Load Items
    private func loadItems() {
        downloadItemsFromFirebase(category!.id) { (allItems) in
            self.itemArray = allItems
            self.tableView.reloadData()
        }
    }

}


extension ItemsTableViewController: EmptyDataSetSource, EmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        return NSAttributedString(string: "No itmes to display!")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "emptyData")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Please check back later")
    }
    
}
