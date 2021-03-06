//
//  SignUpViewController.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/06/19.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var selfImageView: UIImageView!
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    private func setupLayout() {
        
        selfImageView.layer.borderWidth = 0.5
        selfImageView.layer.borderColor = UIColor.black.cgColor
        selfImageView.layer.masksToBounds = false
        selfImageView.layer.cornerRadius = selfImageView.frame.size.width * 0.5
        selfImageView.clipsToBounds = true
        usernameTextfield.layer.borderWidth = 0.5
        usernameTextfield.layer.borderColor = UIColor.black.cgColor
        usernameTextfield.delegate = self
        emailTextfield.layer.borderWidth = 0.5
        emailTextfield.layer.borderColor = UIColor.black.cgColor
        emailTextfield.delegate = self
        passwordTextfield.layer.borderWidth = 0.5
        passwordTextfield.layer.borderColor = UIColor.black.cgColor
        passwordTextfield.delegate = self
        signUpButton.layer.borderWidth = 0.5
        signUpButton.layer.borderColor = UIColor.black.cgColor
        signUpButton.isEnabled = false
        loginButton.layer.borderWidth = 0.5
        loginButton.layer.borderColor = UIColor.black.cgColor
        
        selfImageView.isUserInteractionEnabled = true
        selfImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(_:))))
    }
    
    @objc func imageViewTapped(_ sender: UITapGestureRecognizer) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.image"]
        present(imagePickerController,animated: true,completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let setImage = (info[.originalImage] as! UIImage)
        self.selfImageView.image = setImage
        
        picker.dismiss(animated: true)
    }
    
    @IBAction func registerAccount(_ sender: Any) {
        
        guard let email = emailTextfield.text else { return }
        guard let password = passwordTextfield.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            
            if let user = authResult?.user {
                user.sendEmailVerification(completion: { error in
                    
                    if error == nil {
                        let alert = UIAlertController(title: "??????????????????????????????", message: "??????????????????????????????????????????????????????????????????????????????", preferredStyle: .alert)
                        
                        let addActionAlert: UIAlertAction = UIAlertAction(title: "??????", style: .default, handler: { _ in
                            
                            self.signUpUser()
                            alert.dismiss(animated: false, completion: nil)
                        })
                        
                        alert.addAction(addActionAlert)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    func signUpUser() {
        
        guard let email = self.emailTextfield.text else { return }
        guard let password = self.passwordTextfield.text else { return }
        guard let username = self.usernameTextfield.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            
            if let authResult = authResult {
                
                let user = authResult.user
                if user.isEmailVerified {
                    
                    if let imageData = self.selfImageView.image?.jpegData(compressionQuality: 0.5) {
                        
                        let filename = NSUUID().uuidString
                        let storageRef = Storage.storage().reference().child("profile_image").child(filename)
                        
                        storageRef.putData(imageData, metadata: nil) { _, err in
                            
                            if let err = err {
                                print("??????????????????????????????????????????\(err)")
                                return
                            }
                            
                            storageRef.downloadURL { url, _ in
                                
                                if let imageUrl = url?.absoluteString {
                                    
                                    let storeData: [String: Any] = ["username": username,
                                                                    "email": email,
                                                                    "createdAt": Timestamp(),
                                                                    "profileImageUrl": imageUrl]
                                    
                                    Firestore.firestore().collection("users").document(user.uid).setData(storeData) {_ in
                                        self.performSegue(withIdentifier: "goHome", sender: nil)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    print("mail?????????????????????????????????")
                }
            } else {
                print("user?????????????????????????????????")
            }
            
            if error != nil {
                print("Cant Sign in user")
            }
        }
    }
    
    @IBAction func goBackView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let usernameIsEmpty = usernameTextfield.text?.isEmpty ?? false
        let emailIsEmpty = emailTextfield.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextfield.text?.isEmpty ?? false
        
        if emailIsEmpty || passwordIsEmpty || usernameIsEmpty {
            signUpButton.isEnabled  = false
            return
        }
        
        signUpButton.isEnabled = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
