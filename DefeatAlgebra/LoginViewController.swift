//
//  LoginViewController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/04/08.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import Firestore

class LoginViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate {
    
    var uid: String!
    var schoolCategory: String = "A"
    var username: String!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    var categoryList = ["A", "B"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Auth.auth().signInAnonymously() { (user, error) in
            if let error = error {
                assertionFailure("Error signing in: \(error.localizedDescription)")
                return
            }
            self.uid = user!.uid
        }
        
        categoryPickerView.dataSource = self
        categoryPickerView.delegate = self
        nameTextField.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        username = nameTextField.text
        self.view.endEditing(true)
    }
    
    @IBAction func nameEditEnd(_ sender: UITextField) {
        username = sender.text
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        nameTextField.endEditing(true)
        if let uid = uid, let username = username, username != "" {
            LoginService.create(uid: uid, schoolCategory: schoolCategory, username: username){ (user) in
                guard let user = user else { return }
                User.setCurrent(user, writeToUserDefaults: true)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let next = storyboard.instantiateInitialViewController() as! GameViewController
                self.present(next, animated: true, completion: nil)
            }
        } else {
            print(uid)
            print(schoolCategory)
            print(username)
            print("please fill in name field")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

extension LoginViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        nameTextField.endEditing(true)
        schoolCategory = categoryList[row]
    }
}
