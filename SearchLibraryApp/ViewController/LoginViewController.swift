//
//  LoginViewController.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/06/19.
//

import UIKit
import Firebase
import PKHUD

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
        
        loginEmailTextField.layer.borderWidth = 0.5
        loginEmailTextField.layer.borderColor = UIColor.black.cgColor
        loginEmailTextField.delegate = self
        
        loginPasswordTextFeild.layer.borderWidth = 0.5
        loginPasswordTextFeild.layer.borderColor = UIColor.black.cgColor
        loginPasswordTextFeild.delegate = self
        
        signUpButton.layer.borderWidth = 0.5
        signUpButton.layer.borderColor = UIColor.black.cgColor
        
        loginButton.layer.borderWidth = 0.5
        loginButton.layer.borderColor = UIColor.black.cgColor
        loginButton.isEnabled = false
        
        if Auth.auth().currentUser != nil {
            print("ログイン状態のユーザーが存在します")
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "goHome", sender: nil)
            }
        } else {
            print("ユーザーが存在しません")
        }
    }
    
    @IBAction func Login(_ sender: Any) {
        
        guard let email = loginEmailTextField.text else { return }
        guard let password = loginPasswordTextFeild.text else { return }
        
        HUD.show(.progress)
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, err) in
            if err != nil {
                HUD.hide()
                print("エラーが発生しました\(err)")
                return
            }
            
            if let authResult = authResult {
                let user = authResult.user
                if user.isEmailVerified {
                    HUD.hide()
                    print("ログインに成功しました")
                    
                    self.loginEmailTextField.text = ""
                    self.loginPasswordTextFeild.text = ""
                    self.loginButton.isEnabled = false
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "goHome", sender: nil)
                    }
                }
                return
            }
            
            HUD.hide()
            print("ログインに失敗しました")
        }
    }
    
    @IBAction func goLoginView(_ sender: Any) {
        self.performSegue(withIdentifier: "goSignUp", sender: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = loginEmailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = loginPasswordTextFeild.text?.isEmpty ?? false
        
        if emailIsEmpty || passwordIsEmpty {
            loginButton.isEnabled  = false
            return
        }
        
        loginButton.isEnabled = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
