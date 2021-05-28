//
//  Constants.swift
//  Market
//
//  Created by Conor Andrews on 21/04/2021.
//

import Foundation

enum Constants {
    static let publishableKey = "pk_test_51IoNmJIBUES93qCqKgKSF2PBhoQrFpqPlFQLmi2dJzLkBrrg4YpQgQ8p0jbnx2J4xPzHMEmloKYxAW3sqH63yZeg00hBoJqww4"
    static let baseURLString = "https://prettyinpaper.herokuapp.com"//"http://localhost:3000/"
    static let defaultCurrency = "gbp"
    static let defaultDescription = "Purchase from PrettyInPaper"
}

// IDs and Keys
public let kFILEREFERENCE = "gs://marketca-56bb7.appspot.com"
public let kALGOLIA_APP_ID = "S5JEZUCGAO"
public let kALGOLIA_SEARCH_KEY = "3d27090f97ef66278e1c70c151266403"
public let kALGOLIA_ADMIN_KEY =  "746448474c4bcf09c04d171cb002c43a"

// Firebase Headers
public let kUSER_PATH = "User"
public let kCATEGORY_PATH = "Category"
public let kITEMS_PATH = "Items"
public let kBASKET_PATH = "Basket"
public let kORDER_PATH = "Order"

// Category
public let kNAME = "name"
public let kIMAGENAME = "imageName"
public let kOBJECTID = "objectId"

// Item
public let kCATEGORYID = "categoryId"
public let kDESCRIPTION = "description"
public let kPRICE = "price"
public let kIMAGELINKS = "imageLinks"

// Order
public let kORDERID = "id"
public let kORDERNUMBER = "orderNumber"
public let kORDERDATE = "orderDate"
public let kTOTALPRICE = "price"
public let kUSERID = "userId"
public let kORDERITEMS = "orderItems"
public let kCURRENTORDER = "currentOrder"

// Basket
public let kOWNERID = "ownerId"
public let kITEMIDS = "itemIds"

// User
public let kEMAIL = "email"
public let kFIRSTNAME = "firstName"
public let kLASTNAME = "lastName"
public let kFULLNAME = "fullName"
public let kCURRENTUSER = "currentUser"
public let kFULLADDRESS = "fullAddress"
public let kONBOARD = "onBoard"
public let kPURCHASEDITEMIDS = "purchasedItemIds"
public let kCOMPLETEDORDERIDS = "completedOrderIds"
