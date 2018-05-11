//
//  User.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/04/08.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import Firestore.FIRDocumentSnapshot

class User: NSObject {
    
    // MARK: - Properties
    
    let uid: String
    let username: String
    let schoolCategory: String
    
    // MARK: - Init
    
    init(uid: String, username: String, schoolCategory: String) {
        self.uid = uid
        self.username = username
        self.schoolCategory = schoolCategory
        
        super.init()
    }
    
    init?(document: DocumentSnapshot) {
        guard let dict = document.data() as? [String : Any],
            let username = dict["username"] as? String,
            let schoolCategory = dict["schoolCategory"] as? String
            else { return nil }
        
        self.uid = document.documentID
        self.username = username
        self.schoolCategory = schoolCategory
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let uid = aDecoder.decodeObject(forKey: "uid") as? String,
            let username = aDecoder.decodeObject(forKey: "username") as? String,
            let schoolCategory = aDecoder.decodeObject(forKey: "schoolCategory") as? String
            else { return nil }
        
        self.uid = uid
        self.username = username
        self.schoolCategory = schoolCategory
        
        super.init()
    }
    
    private static var _current: User?
    
    static var current: User {
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }
        return currentUser
    }
    
    // MARK: - Class Methods
    
    class func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
        
        if writeToUserDefaults {
            let data = NSKeyedArchiver.archivedData(withRootObject: user)
            UserDefaults.standard.set(data, forKey: "currentUser")
        }
        
        _current = user
    }
}

extension User: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uid, forKey: "uid")
        aCoder.encode(username, forKey: "username")
        aCoder.encode(schoolCategory, forKey: "schoolCategory")
    }
}
