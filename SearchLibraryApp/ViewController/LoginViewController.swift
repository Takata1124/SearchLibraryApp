//
//  LoginViewController.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/06/19.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginEmailTextField: UITextField!
    @IBOutlet weak var loginPasswordTextFeild: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
 
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }
    
    private func setupLayout() {
        
        self.loginEmailTextField.layer.borderWidth = 0.5
        self.loginEmailTextField.layer.borderColor = UIColor.black.cgColor
        self.loginPasswordTextFeild.layer.borderWidth = 0.5
        self.loginPasswordTextFeild.layer.borderColor = UIColor.black.cgColor
        signUpButton.layer.borderWidth = 0.5
        signUpButton.layer.borderColor = UIColor.black.cgColor
        loginButton.layer.borderWidth = 0.5
        loginButton.layer.borderColor = UIColor.black.cgColor
    }
    
    @IBAction func goLoginView(_ sender: Any) {
        self.performSegue(withIdentifier: "goSignUp", sender: nil)
    }
}
