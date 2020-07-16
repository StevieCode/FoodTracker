//
//  Meal.swift
//  FoodTracker
//
//  Created by Steve Feng on 2020/6/30.
//  Copyright © 2020 Steve Feng. All rights reserved.
//

import UIKit
import os.log

class Meal: NSObject, NSCoding {
    
    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(rating, forKey: PropertyKey.rating)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // If we cannot decode a string, the decoder should fail
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        let rating = aDecoder.decodeInteger(forKey: PropertyKey.rating)
        
        // Must call designated initilizer
        self.init(name: name, photo: photo, rating: rating)
        
    }
    
    // MARK: Properties
    var name: String
    var photo: UIImage?
    var rating: Int
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meal")
    
    // MARK: Types
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let rating = "rating"
    }
    
    // MARK: Initilization
    init?(name: String, photo: UIImage?, rating: Int) {
        // Value Check
        if name.isEmpty || rating < 0 {
            return nil
        }
        
        self.name = name
        self.photo = photo
        self.rating = rating
    }
}
