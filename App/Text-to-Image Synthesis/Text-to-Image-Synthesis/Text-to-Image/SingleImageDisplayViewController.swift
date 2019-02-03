//
//  SingleImageDisplayViewController
//  Text-to-Image-Synthesis
//
//  Created by Ryan Kang on 11/21/18.
//

import UIKit

class SingleImageDisplayViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    var voiceCommandText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = voiceCommandText
        loadImage(voiceCommandText)
    }
    
    //MARK: - ImageView Helper functions
    private func loadImage(_ voiceCommandText: String) {
        let fetcher = ImageFetcher()
        print("Downloading Started For: " + voiceCommandText)
        fetcher.fetchImageWithText(commandText: voiceCommandText) { data, response, error in
            if let error = error {
                print("Image fetch failed with error: \(error)")
                self.sendAlert(message: "There has been an error while fetching the image.")
            }
            
            if let data = data {
                print("Download Finished For: " + data.description)
                DispatchQueue.main.async() {
                    self.updateViewWithImage(data)
                }
            }
        }
    }
    
    private func updateViewWithImage(_ data: Data) {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.contentMode = UIView.ContentMode.scaleAspectFit
        self.imageView.image = UIImage(data: data)
    }
    
    // MARK: - Alert
    private func sendAlert(message: String) {
        let alert = UIAlertController(title: "Image Fetch Error",
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
