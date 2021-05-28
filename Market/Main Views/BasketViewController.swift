//
//  BasketViewController.swift
//  Market
//
//  Created by Conor Andrews on 07/05/2021.
//  Copyright © 2021 Conor Andrews. All rights reserved.
//

import UIKit
import JGProgressHUD
import Stripe
import SwiftSMTP

class BasketViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var checkoutButtonOutlet: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalItemsLabel: UILabel!
    @IBOutlet weak var basketTotalPriceLabel: UILabel!
    
    //MARK: - Vars
    var basket: Basket?
    var allItems: [Item] = []
    var order: Order!
    var purchasedItemIds: [String] = []
    var completedOrderIds: [String] = []
    
    let hud = JGProgressHUD(style: .dark)
    var totalPrice = 0
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = footerView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if MUser.currentUser() != nil {
            loadBasketFromFirestore()
        } else {
            self.updateTotalLabels(true)
        }
    }
    
    //MARK: - IBActions
    @IBAction func checkoutButtonPressed(_ sender: Any) {

        if MUser.currentUser()!.onBoard {
            showPaymentOptions()
        } else {
            self.showNotification(text: "Please complete your profile!", isError: true)
        }
    }
    
    //MARK: - Download basket
    private func loadBasketFromFirestore() {
        
        downloadBasketFromFirestore(MUser.currentId()) { (basket) in

            self.basket = basket
            self.getBasketItems()
        }
    }
    
    private func getBasketItems() {
        
        if basket != nil {
            
            downloadItems(basket!.itemIds) { (allItems) in

                self.allItems = allItems
                self.updateTotalLabels(false)
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - Helper functions
    private func updateTotalLabels(_ isEmpty: Bool) {
        
        if isEmpty {
            totalItemsLabel.text = "0"
            basketTotalPriceLabel.text = returnBasketTotalPrice()
        } else {
            totalItemsLabel.text = "\(allItems.count)"
            basketTotalPriceLabel.text = returnBasketTotalPrice()
        }
        checkoutButtonStatusUpdate()
    }
    
    private func returnBasketTotalPrice() -> String {
        
        var totalPrice = 0.0
        
        for item in allItems {
            totalPrice += item.price
        }
        return "Total price: " + convertToCurrency(totalPrice)
    }
    
    private func emptyTheBasket() {
        
        purchasedItemIds.removeAll()
        allItems.removeAll()
        tableView.reloadData()
        
        basket!.itemIds = []
        
        updateBasketInFirestore(basket!, withValues: [kITEMIDS : basket!.itemIds]) { (error) in
            
            if error != nil {
                print("Error updating basket ", error!.localizedDescription)
            }
            self.getBasketItems()
        }
    }
    
    private func addItemsToPurchaseHistory(_ itemIds: [String]) {
        
        if MUser.currentUser() != nil {
            
            print("item ids , ", itemIds)
            let newItemIds = MUser.currentUser()!.purchasedItemIds + itemIds
            
            updateCurrentUserInFirestore(withValues: [kPURCHASEDITEMIDS : newItemIds]) { (error) in
                
                if error != nil {
                    print("Error adding purchased items ", error!.localizedDescription)
                }
            }
        }
    }
    
    private func addOrderToOrderHistory(_ orderId: [String]) {
        
        if MUser.currentUser() != nil {
            
            print("Order ids, ", orderId)
            let newOrderId = MUser.currentUser()!.completedOrderIds + orderId
            
            updateCurrentUserInFirestore(withValues: [kCOMPLETEDORDERIDS : newOrderId]) { (error) in
                
                if error != nil {
                    print("Error adding completed order ", error!.localizedDescription)
                }
            }
        }
    }
    
    //MARK: - Navigation
    private func showItemView(withItem: Item) {
        
        let itemVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "itemView") as! ItemViewController
        
        itemVC.item = withItem
        
        self.navigationController?.pushViewController(itemVC, animated: true)
    }

    //MARK: - Control checkoutButton
    private func checkoutButtonStatusUpdate() {
        
        checkoutButtonOutlet.isEnabled = allItems.count > 0
        
        if checkoutButtonOutlet.isEnabled {
            checkoutButtonOutlet.backgroundColor = #colorLiteral(red: 0.2425246239, green: 0.5274564624, blue: 0.9168085456, alpha: 1)
        } else {
            disableCheckoutButton()
        }
    }

    private func disableCheckoutButton() {
        checkoutButtonOutlet.isEnabled = false
        checkoutButtonOutlet.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
    }
    
    private func removeItemFromBasket(itemId: String) {
        
        for i in 0..<basket!.itemIds.count {
            
            if itemId == basket!.itemIds[i] {
                basket!.itemIds.remove(at: i)
                
                return
            }
        }
    }

    private func finishPayment(token: STPToken) {
        
        self.totalPrice = 0
        
        for item in allItems {
            purchasedItemIds.append(item.id)
            self.totalPrice += Int(item.price)
        }
        dump(purchasedItemIds)
        let orderTotal = Double(self.totalPrice)
        
        let date = Date()
        let formatDate = DateFormatter()
        let formatOrderNum = DateFormatter()
        formatDate.dateFormat = "dd/MM/yyyy"
        formatOrderNum.dateFormat = "ddMMyyyy"
        let formattedDate = formatDate.string(from: date)
        let formattedOrderNum = formatOrderNum.string(from: date)
        
        let order = Order()
        order.id = UUID().uuidString
        order.orderNumber = formattedOrderNum + "-" + randomString(length: 10)
        order.date = formattedDate
        order.totalPrice = orderTotal
        order.userId = MUser.currentId()
        order.orderItems = purchasedItemIds
        dump(order)
        completedOrderIds.append(order.id)
        
        self.totalPrice = self.totalPrice * 100
        
        StripeClient.sharedClient.createAndConfirmPayment(token, amount: totalPrice) { (error) in
            
            if error == nil {
                self.addOrderToOrderHistory(self.completedOrderIds)
                saveOrderToFirestore(order)
                self.addItemsToPurchaseHistory(self.purchasedItemIds)
                self.emptyTheBasket()
                self.sendConfirmationEmail()
                self.showNotification(text: "Payment Successful", isError: false)
            } else {
                self.showNotification(text: error!.localizedDescription, isError: true)
                print("error ", error!.localizedDescription)
            }
        }
    }
    
    private func randomString(length: Int) -> String {

        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)

        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
    }

    private func showNotification(text: String, isError: Bool) {
        
        if isError {
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
        } else {
            self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        }
        
        self.hud.textLabel.text = text
        self.hud.show(in: self.view)
        self.hud.dismiss(afterDelay: 2.0)
    }
    
    private func sendConfirmationEmail() {
        
        StripeClient
    }
    
    private func showPaymentOptions() {
        
        let alertController = UIAlertController(title: "Payment Options", message: "Choose prefered payment option", preferredStyle: .actionSheet)
        
        let cardAction = UIAlertAction(title: "Pay with Card", style: .default) { (action) in
            
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "cardInfoVC") as! CardInfoViewController

            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(cardAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension BasketViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        
        cell.generateCell(allItems[indexPath.row])
        
        return cell
    }
    
    //MARK: - UITableview Delegate
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let itemToDelete = allItems[indexPath.row]
            
            allItems.remove(at: indexPath.row)
            tableView.reloadData()
            
            removeItemFromBasket(itemId: itemToDelete.id)

            updateBasketInFirestore(basket!, withValues: [kITEMIDS : basket!.itemIds]) { (error) in
                
                if error != nil {
                    print("error updating the basket", error!.localizedDescription)
                }
                self.getBasketItems()
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(withItem: allItems[indexPath.row])
    }
}

extension BasketViewController: CardInfoViewControllerDelegate {

    func didClickDone(_ token: STPToken) {
        finishPayment(token: token)
    }

    func didClickCancel() {
        showNotification(text: "Payment Cancelled", isError: true)
    }
}
