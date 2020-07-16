//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by Steve Feng on 2020/6/30.
//  Copyright © 2020 Steve Feng. All rights reserved.
//

import UIKit
import os.log

class MealTableViewController: UITableViewController {
    
    // MARK: Properties
    var meals = [Meal]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Load any saved Meals, otherwise load sample data.
        if let savedMeals = loadMeals() {
            meals += savedMeals
        } else {
            loadSampleMeals()
        }
      
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MealTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MealTableViewCell else {
            fatalError("The dequeued element is not an instance of MealTableViewCell")
        }
        
        // Fetch the appropriate data for display
        let meal = meals[indexPath.row]
        
        // Config cell
        cell.nameLabel.text = meal.name
        cell.photoImageView?.image = meal.photo
        cell.ratingControl.rating = meal.rating
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingSytle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        
        if editingSytle == .delete {
            // Delete the row form the data source
            meals.remove(at: indexPath.row)
            saveMeals()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingSytle == .insert {
            // Create a new instance of the appropriate class, insert it into the array,
            // and add a new row to table view
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specific item to be editable
        return true
    }
    
    // MARK: Navigation
    
    // Preparation before navigating
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the destination view and pass it to the new view controller
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let mealDetailViewController = segue.destination as? MealViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedMealCell = sender as? MealTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedMeal = meals[indexPath.row]
            mealDetailViewController.meal = selectedMeal
        default:
            fatalError("Unexpected segue identifier: \(segue.identifier)")
        }
        
    }
    
    
    
    // MARK: Actions
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MealViewController, let meal = sourceViewController.meal {
            // Checks whether a row in the table view is selected
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update existing meal
                meals[selectedIndexPath.row] = meal
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                
                // Add a new meal
                let newIndexPath = IndexPath(row: meals.count, section: 0)
                
                meals.append(meal)
                // Save the meals.
                saveMeals()
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
        }
    }
    
    // MARK: Private methods
    
    private func loadSampleMeals() {
        
    }
    // Helper function that loads sample data into app
    /*
    private func loadSampleMeals() {
        // Load images
        let photo1 = UIImage(named: "pic1")
        let photo2 = UIImage(named: "pic2")
        let photo3 = UIImage(named: "pic3")
        
        // Create meal objects
        guard let meal1 = Meal(name: "Patrick Thompson", photo: photo1, rating: 4) else {
            fatalError("Unable to instantiate meal1")
        }
        
        guard let meal2 = Meal(name: "Nick Young", photo: photo2, rating: 5) else {
            fatalError("Unable to instantiate meal2")
        }
        
        guard let meal3 = Meal(name: "Movie kid", photo: photo3, rating: 2) else {
            fatalError("Unable to instantiate meal3")
        }
        
        // Append meals to the array
        meals += [meal1, meal2, meal3]
    }
   */
    
    private func saveMeals() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: Meal.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save meals...", log: OSLog.default, type: .debug)
        }
    }
    
    private func loadMeals() -> [Meal]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURL.path) as? [Meal]
    }
    
}
