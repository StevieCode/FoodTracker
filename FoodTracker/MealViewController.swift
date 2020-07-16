//
//  ViewController.swift
//  FoodTracker
//
//  Created by Steve Feng on 2020/6/23.
//  Copyright © 2020 Steve Feng. All rights reserved.
//

import UIKit
import os.log

class MealViewController: UIViewController, UITextFieldDelegate,
                      UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var meal: Meal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Handle the text field's use input through delegate callbacks
        // Make the ViewController class the delegate of the textfield
        nameTextField.delegate = self
        
        // Setup view if viewing an existing meal
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text = meal.name
            photoImageView.image = meal.photo
            ratingControl.rating = meal.rating
        }
        
        // Allow navigation only if the user has inputed something
        updateSaveButtonState()
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the save button while editing
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = nameTextField.text
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Use the original file out of the potential multiple versions
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photo image view to display the selected image
        photoImageView.image = selectedImage
        
        // Dismiss the picker
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push),
        // this view controller needs to be dismissed in two different ways
        let isAdding = presentingViewController is UINavigationController
        
        if isAdding {
            dismiss(animated: true, completion: nil)
        } else if let ownNavigationController = navigationController {
            ownNavigationController.popViewController(animated: true)
        } else {
            fatalError("The MealViewController is not inside a navigation controller")
        }
        
    }
    
    // Config a view contoller before it is presented
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Config the destination view only if the save button is pressed
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button is not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = nameTextField.text ?? ""
        let photo = photoImageView.image
        let rating = ratingControl.rating
        
        // Set the meal to passed to MealViewController to unwind the segue
        meal = Meal(name: name, photo: photo, rating: rating)
        
        
    }

    // MARK: Actions
    
    // Define the action after tapping the image
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        // Hide the keyboard
        nameTextField.resignFirstResponder()
        
        // Set up alert to choose between photo lib or take a pic
        let alert = UIAlertController(title: "Choose image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take a picture", style: .default, handler: {_ in self.openCamera()}))
        alert.addAction(UIAlertAction(title: "Choose from library", style: .default, handler: {_ in self.openGallary()}))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        // Present alert
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Private methods
    private func updateSaveButtonState() {
        // Disable the save button if the textfield is empty
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    // Helper function that allow the user to take a picture and use it as the image
    private func openCamera() {
        let imagePicker = UIImagePickerController()
        
        // Check if the user has a camera
        if (UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Warning", message: "You don't have a camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        imagePicker.delegate = self
    }
    
    // Helper function that allows the user to choose a picture from the library
    private func openGallary() {
        let imagePicker = UIImagePickerController()
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        
        imagePicker.delegate = self
    }
    
   
}

