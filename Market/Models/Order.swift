//
//  Order.swift
//  Market
//
//  Created by Conor Andrews on 07/05/2021.
//  Copyright © 2021 Conor Andrews. All rights reserved.
//

import Foundation
import UIKit
import InstantSearchClient
import FirebaseAuth

class Order {
    
    // MARK: Vars
    var id: String!
    var orderNumber: String!
    var date: String!
    var totalPrice: Double!
    var userId: String!
    var orderItems: [String]!
    
    // MARK: Initializer
    init() {
    }
    
    init(_dictionary: NSDictionary) {
        
        id = _dictionary[kORDERID] as? String
        orderNumber = _dictionary[kORDERNUMBER] as? String
        date = _dictionary[kORDERDATE] as? String
        totalPrice = _dictionary[kTOTALPRICE] as? Double
        userId = _dictionary[kUSERID] as? String
        orderItems = _dictionary[kORDERITEMS] as? [String]
    }
    
    class func currentOrder() -> Order? {
        
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.object(forKey: kCURRENTORDER) {
                dump(dictionary)
                return Order.init(_dictionary: dictionary as! NSDictionary)
            }
        }
        
        return nil
    }
}


//MARK: Save items func

func saveOrderToFirestore(_ order: Order) {
    
    FirebaseReference(.Orders).document(order.id).setData(orderDictionaryFrom(order) as! [String : Any])
}


//MARK: Helper functions

func orderDictionaryFrom(_ order: Order) -> NSDictionary {
    
    return NSDictionary(objects: [order.id, order.orderNumber, order.date, order.totalPrice, order.userId, order.orderItems], forKeys: [kORDERID as NSCopying, kORDERNUMBER as NSCopying, kORDERDATE as NSCopying, kTOTALPRICE as NSCopying, kUSERID as NSCopying, kORDERITEMS as NSCopying])
}


//MARK: Download Func
func downloadOrdersFromFirebase(_ withUserId: String, completion: @escaping (_ orderArray: [Order]) -> Void) {
    
    var orderArray: [Order] = []
    
    FirebaseReference(.Orders).whereField(kUSERID, isEqualTo: withUserId).getDocuments { (snapshot, error) in
        
        guard let snapshot = snapshot else {
            completion(orderArray)
            return
        }
        
        if !snapshot.isEmpty {
            
            for orderDict in snapshot.documents {
                
                orderArray.append(Order(_dictionary: orderDict.data() as NSDictionary))
            }
        }
        
        completion(orderArray)
    }
    
}

func downloadOrders(_ withIds: [String], completion: @escaping (_ orderArray: [Order]) -> Void) {
    
    var count = 0
    var orderArray: [Order] = []
    
    if withIds.count > 0 {
        
        for orderId in withIds {

            FirebaseReference(.Orders).document(orderId).getDocument { (snapshot, error) in
                
                guard let snapshot = snapshot else {
                    completion(orderArray)
                    return
                }

                if snapshot.exists {

                    orderArray.append(Order(_dictionary: snapshot.data()! as NSDictionary))
                    count += 1
                }
                
                if count == withIds.count {
                    completion(orderArray)
                }
            }
        }
    } else {
        completion(orderArray)
    }
}
