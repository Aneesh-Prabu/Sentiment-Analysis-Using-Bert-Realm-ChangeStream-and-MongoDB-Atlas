//
//  MoviesViewController.swift
//  Peerstagram
//
//  Created by Aneesh Prabu on 2/2/22.
//

import UIKit
import RealmSwift
import BLTNBoard

class MoviesViewController: UIViewController {
    
    
    @IBOutlet weak var reviewBtn: UIButton!
    var realm:Realm?
    
    lazy var bulletinManagerReviewMovie: BLTNItemManager = {
        
        
        // Textfield in bulletin board
        let page = MovieReviewBulletinPage(title: "Please review a movie")
        
        // Description under
        page.descriptionText = "Please name a movie and review it!"
        
        // Button Title
        page.actionButtonTitle = "Submit"
        
        // Touch anywhere on the screen to dismiss bulletin board
        page.isDismissable = true
        
        // Popcorn image.. yay!!
        page.image = UIImage(systemName: "text.bubble.fill")
        
        // Login button color (MongoDB Green)
        page.appearance.actionButtonColor = UIColor(red: 63/255, green: 160/255, blue: 55/255, alpha: 1.0)
        
        // What happens if you click the login button
        page.actionHandler = { (item: BLTNActionItem) in
            
            // Get the text inside textfield
            if let movieName = page.movieName.text, let movieReview = page.movieReview.text {
                
                //Check if user ID is empty
                if movieName != "" && movieReview != "" {
                    
                    let movieModel = Movie(name: movieName, review: movieReview)
                    
                    if let realmSync = self.realm {
                        // Persist user model and sync with Realm
                        try! realmSync.write {
                            realmSync.add(movieModel)
                        }
                        
                        // Dismiss Bulletinboard: [Bug exists!] [TODO]
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                else {
                    // Dismiss Bulletinboard (Future implementation)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        // Returning BLTN Manager to be used to present View
        return BLTNItemManager(rootItem: page)
    }()

    //MARK: - Review Button Pressed
    @IBAction func reviewBtnPressed(_ sender: UIButton) {
        /**
            When review button is pressed show bulletin manager
         */
        
        // Background of bulletin is blurred
        bulletinManagerReviewMovie.backgroundViewStyle = .blurredDark
        
        // Present bulletin board
        bulletinManagerReviewMovie.showBulletin(above: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Dismiss Bulletinboard: [Bug exists!] [TODO]
        // self.dismiss(animated: true, completion: nil)
    }
}



//MARK: - Bullet In board methods and classes
class MovieReviewBulletinPage: BLTNPageItem, UITextFieldDelegate {
    
    /**
    
        This class is for adding textfield inside bulletin board manager
     
     */
    
    // UserID Textfield
    var movieName: UITextField!
    var movieReview: UITextField!

    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        
        movieName = interfaceBuilder.makeTextField(placeholder: "Movie name", returnKey: .done, delegate: self)
        movieReview = interfaceBuilder.makeTextField(placeholder: "Review", returnKey: .done, delegate: self)
        
        movieName.autocapitalizationType = .words
        movieName.autocorrectionType = .no
        
        movieReview.keyboardType = .default
        movieReview.autocorrectionType = .yes
        movieReview.autocapitalizationType = .none
        
        return [movieName, movieReview]
    }
}
