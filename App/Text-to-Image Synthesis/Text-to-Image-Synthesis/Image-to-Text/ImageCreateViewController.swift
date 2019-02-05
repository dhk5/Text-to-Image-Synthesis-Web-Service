//
//  ImageCreateViewController.swift
//  Text-to-Image-Synthesis
//
//  Created by Ryan Kang on 1/22/19.
//

import UIKit

class ImageCreateViewController: UIViewController {
    @IBOutlet weak var mainNoundImageView: UIImageView!
    @IBOutlet weak var dependenNounImageView: UIImageView!
    @IBOutlet weak var imageDescriptionLabel: UILabel!
    @IBOutlet weak var generateButton: UIButton!
    
    var arrSelectedData: [ImageData] = [ImageData]()
    var mainNoundImageTitle: String = ""
    var dependentNounImageTitle: String = ""
    var imagePreposition: String = "Above"
    let titleText = "Drag and Drop the Images"
    let imageHeight = 150
    let imageWidth = 150
    
    lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(self.handlePan))
    }()
    
    @IBAction func generateButtonTapped(_ sender: Any) {
        imageDescriptionLabel.text = "\(mainNoundImageTitle) \(imagePreposition) \(dependentNounImageTitle)"
    }
    
    @objc
    private func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.mainNoundImageView)
        if let view = self.mainNoundImageView {
            view.center = CGPoint(x:view.center.x + translation.x, y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: self.mainNoundImageView)
        
        switch recognizer.state {
        case .ended, .cancelled:
            calculateDistance()
        default:
            break
        }
    }
    
    private func calculateDistance() {
        let locationDifferenceX = dependenNounImageView.center.x - mainNoundImageView.center.x
        let locationDifferenceY = dependenNounImageView.center.y - mainNoundImageView.center.y
        print("Image Location Difference: \(locationDifferenceX), \(locationDifferenceY)")
        
        if -10 < locationDifferenceX && locationDifferenceX < 10 && 
            140 < locationDifferenceY && locationDifferenceY < 160 {
            imagePreposition = "On"
        } else if -10 < locationDifferenceX && locationDifferenceX < 10 &&
            -160 < locationDifferenceY && locationDifferenceY < -140 {
            imagePreposition = "Under"
        } else if (-160 < locationDifferenceX && locationDifferenceX < -140 ||
            140 < locationDifferenceX && locationDifferenceX < 160) &&
            -10 < locationDifferenceY && locationDifferenceY < 10 {
            imagePreposition = "Beside"
        } else if -50 < locationDifferenceX && locationDifferenceX < 50 &&
            140 < locationDifferenceY {
            imagePreposition = "Above"
        } else if -50 < locationDifferenceX && locationDifferenceX < 50 &&
            locationDifferenceY < -140 {
            imagePreposition = "Below"
        } else {
            imagePreposition = "Near"
        }
        generateButton.isEnabled = true
    }
}

// MARK: - UIViewController
extension ImageCreateViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(panGestureRecognizer)
        setUp()
    }

    private func setUp() {
        title = titleText
        generateButton.isEnabled = false
        mainNoundImageView.translatesAutoresizingMaskIntoConstraints = true
        mainNoundImageView.image = arrSelectedData[0].image
        let mainNounImageName = arrSelectedData[0].imageName
        mainNoundImageTitle = String(mainNounImageName.first!).capitalized + mainNounImageName.dropFirst()
        dependenNounImageView.translatesAutoresizingMaskIntoConstraints = true
        dependenNounImageView.image = arrSelectedData[1].image
        let dependentNounImageName = arrSelectedData[1].imageName
        dependentNounImageTitle = String(dependentNounImageName.first!).capitalized + dependentNounImageName.dropFirst()
    }
}
