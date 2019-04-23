//
//  ImageCreateViewController.swift
//  Text-to-Image-Synthesis
//
//  Created by Ryan Kang on 1/22/19.
//

import UIKit

class ImageCreateViewController: UIViewController {
    @IBOutlet weak var mainNounImageView: UIImageView!
    @IBOutlet weak var dependentNounImageView: UIImageView!
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
        let string = NSMutableAttributedString(string: "\(mainNoundImageTitle) \(imagePreposition) \(dependentNounImageTitle)")
        string.setColorForText("\(mainNoundImageTitle)", with: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))
        string.setColorForText("\(imagePreposition)", with: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        string.setColorForText("\(dependentNounImageTitle)", with: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1))
        imageDescriptionLabel.attributedText = string
    }
    
    @objc
    private func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.mainNounImageView)
        if let view = self.mainNounImageView {
            view.center = CGPoint(x:view.center.x + translation.x, y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: self.mainNounImageView)
        
        switch recognizer.state {
        case .ended, .cancelled:
            calculateDistance()
        default:
            break
        }
    }
    
    private func calculateDistance() {
        let locationDifferenceX = dependentNounImageView.center.x - mainNounImageView.center.x
        let locationDifferenceY = dependentNounImageView.center.y - mainNounImageView.center.y
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
        } else if -50 < locationDifferenceX && locationDifferenceX < 50 &&
            -50 < locationDifferenceY && locationDifferenceY < 50 {
            imagePreposition = "Over"
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
        mainNounImageView.translatesAutoresizingMaskIntoConstraints = true
        mainNounImageView.image = arrSelectedData[0].image
        mainNounImageView.layer.borderWidth = 5
        mainNounImageView.layer.borderColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        let mainNounImageName = arrSelectedData[0].imageName
        mainNoundImageTitle = String(mainNounImageName.first!).capitalized + mainNounImageName.dropFirst()
        dependentNounImageView.translatesAutoresizingMaskIntoConstraints = true
        dependentNounImageView.image = arrSelectedData[1].image
        dependentNounImageView.layer.borderWidth = 5
        dependentNounImageView.layer.borderColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        let dependentNounImageName = arrSelectedData[1].imageName
        dependentNounImageTitle = String(dependentNounImageName.first!).capitalized + dependentNounImageName.dropFirst()
    }
}

extension NSMutableAttributedString {
    
    func setColorForText(_ textToFind: String?, with color: UIColor) {
        let range:NSRange?
        if let text = textToFind{
            range = self.mutableString.range(of: text, options: .caseInsensitive)
        }else{
            range = NSMakeRange(0, self.length)
        }
        if range!.location != NSNotFound {
            addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range!)
        }
    }
}
