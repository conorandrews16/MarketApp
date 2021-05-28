//
//  FirebaseCollectionReference.swift
//  Market
//
//  Created by Conor Andrews on 21/04/2021.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case User
    case Category
    case Items
    case Basket
    case Orders
}

func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}
