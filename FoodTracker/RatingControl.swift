//
//  RatingControl.swift
//  FoodTracker
//
//  Created by Steve Feng on 2020/6/27.
//  Copyright © 2020 Steve Feng. All rights reserved.
//

import UIKit

@IBDesignable
class RatingControl: UIStackView {
    // MARK: Properties
    private var ratingButtons = [UIButton]()
    
    var rating = 0 {
        didSet {
            updateButtonSelectionStates()
        }
    }
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }

    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    // MARK: Private Methods
    private func setupButtons() {
        // Clear out existing button
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        // Load images for buttons from assets
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        
        // Create 5 buttons
        for index in 0..<starCount {
            // Create a button
            let button = UIButton()
            
            // Setup button images
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            // Add constraints
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            // Add accessibility label
            button.accessibilityLabel = "Set \(1 + index) star rating"
            
            
            // Setuo the button action
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(button:)), for: .touchUpInside)
            
            // Add the button to the stack
            addArrangedSubview(button)
            
            // Add the button to the array
            ratingButtons.append(button)
        }
        
        updateButtonSelectionStates()
    }
    
    // MARK: button actions
    @objc func ratingButtonTapped(button: UIButton) {
        guard let index = ratingButtons.index(of: button) else {
            fatalError("The button \(button) is not in the rating button array \(ratingButtons)")
        }
        
        // Get the score according to the button selected
        let selectedRating = index + 1
        
        // If the selected index is equal to the current rating, reset rating to 0
        // Update it otherwise
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    private func updateButtonSelectionStates() {
        // If the index of the button is less than the rating, it is selected
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
            // Set the hint string for selected star
            let hintString: String?
            if rating == index + 1 {
                hintString = "Tap to reset the rating to zero"
            } else {
                hintString = nil
            }
            
            // Calculate the value of the string
            let valueString: String
            switch (rating) {
            case 0:
                valueString = "No rating set"
            case 1:
                valueString = "1 star set"
            default:
                valueString = "\(rating) star set"
            }
            
            // Assign hint string and value string
            button.accessibilityHint = hintString
            button.accessibilityValue = valueString
        }
        
        
    }
    
    
}
