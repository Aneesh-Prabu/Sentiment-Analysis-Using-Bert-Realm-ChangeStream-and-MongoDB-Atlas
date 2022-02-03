//
//  UserModel.swift
//  Peerstagram
//
//  Created by Aneesh Prabu on 2/2/22.
//

import UIKit
import Realm
import RealmSwift

class UserModel: Object {
    @Persisted (primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted var name: String
    @Persisted var movies = List<Movie>()
    
    
    convenience init(name:String) {
        self.init()
        self.name = name
    }
}

class Movie: Object {
    @Persisted (primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted var name:String?
    @Persisted var review:String?
    @Persisted var sentiment_score:Float = 2.0
    
    convenience init(name:String, review:String) {
        self.init()
        self.name = name
        self.review = review
    }
}
