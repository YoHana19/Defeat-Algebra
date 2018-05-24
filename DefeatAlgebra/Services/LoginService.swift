//
//  LoginService.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/04/08.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import Firestore

class LoginService {
    static func create(uid: String, schoolCategory: String, username: String, completion: @escaping (User?) -> Void) {
        let userAttrs = ["username": username, "schoolCategory": schoolCategory]
        
        let ref = Firestore.firestore().collection("users").document(uid)
        ref.setData(userAttrs) { error in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            
            ref.getDocument() { (document, err) in
                if let document = document {
                    print("Document data: \(document.data())")
                    let user = User(document: document)
                    completion(user)
                } else {
                    print("Document does not exist")
                    completion(nil)
                }
            }
        }
    }
}
