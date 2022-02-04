//
//  ViewController.swift
//  Peerstagram
//
//  Created by Aneesh Prabu on 2/1/22.
//

import UIKit
import BLTNBoard
import Realm
import RealmSwift


class ViewController: UIViewController {
    
    //MARK: - Buttons and IO
    
    @IBOutlet weak var signupBtn: UIButton!
    var realm = try! Realm()
    
    //MARK: - Bulletin Managers
    
    lazy var bulletinManagerLogin: BLTNItemManager = {
        
        
        // Textfield in bulletin board
        let page = TextFieldBulletinPage(title: "Please enter your name")
        
        // Description under
        page.descriptionText = "Please fill in the following information to start reviewing movies!"
        
        // Button Title
        page.actionButtonTitle = "Login"
        
        // Touch anywhere on the screen to dismiss bulletin board
        page.isDismissable = true
        
        // Login button color (MongoDB Green)
        page.appearance.actionButtonColor = UIColor(red: 63/255, green: 160/255, blue: 55/255, alpha: 1.0)
        
        // What happens if you click the login button
        page.actionHandler = { (item: BLTNActionItem) in
            
            // Get the text inside textfield
            if let id = page.userId.text {
                
                //Check if user ID is empty
                if id != "" {
                    
                    // Get app id for MongoDB Realm
                    let app = App(id: "") // Insert your app ID here
                    
                    // Creating anonymous Login
                    let anonymousCredentials = Credentials.anonymous
                    
                    // Using login credentials to log user in Realm
                    app.login(credentials: anonymousCredentials) { (result) in
                        
                        // Check result is failure or success
                        switch result {
                            
                            // If failure to login
                            case .failure(let error):
                                print("Login failed: \(error.localizedDescription)")
                            
                            // If success login return user reference
                            case .success(let user):
                                print("Successfully logged in as user \(user)")
                            
                            // Creating user model
                            let userModel = UserModel(name: id)
                            
                            // Partition ID is _partition which is nothing but generated _id
                            let partitionValue = "\(userModel._id)"
                            
                            // Getting realm configuration of user to maintain in another ViewController
                            self.realm = try! Realm(configuration: user.configuration(partitionValue: partitionValue))
                            
                            // Persist user model and sync with Realm
                            try! self.realm.write {
                                self.realm.add(userModel)
                            }
                            // Dismiss Bulletinboard: [Bug exists!] [TODO]
                            self.dismiss(animated: true, completion: nil)
                            
                            // Perform segue to View Controller
                            self.performSegue(withIdentifier: "goToMovies", sender: self)
                            

                        }
                    }
                }
                else {
                    // Dismiss Bulletinboard (Only for login (Future implementation))
                    self.dismiss(animated: true, completion: nil)
                    self.alert(title: "Error", message: "Please enter all fields!")
                }
            }
        }
        // Returning BLTN Manager to be used to present View
        return BLTNItemManager(rootItem: page)
    }()
    
    //MARK: - Alert function
    /**
     
                Alert View Controller
            
        - Parameter:
                    - title [String]: The title of alert view controller
                    - message [String]: Message to be displayed in alert view controller
        
     */
    func alert(title: String, message: String) {
        // Initialize alert view controller
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add action "ok" in alert view
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        // Add action to alert view controller
        alert.addAction(action)
        
        // Present alert view controller
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Keep background color as white for DEVELOPMENT MODE ONLY
        view.backgroundColor = .white
        
    }
    
    //MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // If segue is for MoviesViewController
        if segue.identifier == "goToMovies" {
            if let destinationVC = segue.destination as? MoviesViewController {
                
                // Assign current realm with configuration to MoviesViewController.realm variable
                destinationVC.realm = self.realm
            }
        }
    }
    
    // MARK: - Button action functions
    @IBAction func signupPressed(_ sender: UIButton) {
        /**
            When signup button is pressed show bulletin manager
         */
        
        // Background of bulletin is blurred
        bulletinManagerLogin.backgroundViewStyle = .blurredDark
        
        // Present bulletin board
        bulletinManagerLogin.showBulletin(above: self)
    }
}

//MARK: - Bullet In board methods and classes
class TextFieldBulletinPage: BLTNPageItem, UITextFieldDelegate {
    
    /**
    
        This class is for adding textfield inside bulletin board manager
     
     */
    
    // UserID Textfield
    var userId: UITextField!
    
    // Textfield Customisation
    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        userId = interfaceBuilder.makeTextField(placeholder: "User ID", returnKey: .done, delegate: self)
        userId.autocapitalizationType = .words
        userId.autocorrectionType = .no
        return [userId]
    }
}

