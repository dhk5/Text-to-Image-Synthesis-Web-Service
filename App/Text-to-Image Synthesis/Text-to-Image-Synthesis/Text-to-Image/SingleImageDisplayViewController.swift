//
//  SingleImageDisplayViewController
//  Text-to-Image-Synthesis
//
//  Created by Ryan Kang on 11/21/18.
//

import UIKit

class SingleImageDisplayViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var vSpinner : UIView?
    
    var voiceCommandText: String = ""
    let info = ProcessInfo.processInfo
    var startTime = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = voiceCommandText
        self.showSpinner(onView: self.view)
        startTime = info.systemUptime
        loadImage(voiceCommandText)
    }
    
    //MARK: - ImageView Helper functions
    private func loadImage(_ voiceCommandText: String) {
        let fetcher = ImageFetcher()
        print("Downloading Started For: " + voiceCommandText)
        fetcher.fetchImageWithText(commandText: voiceCommandText) { data, response, error in
            self.removeSpinner()
            if let error = error {
                print("Image fetch failed with error: \(error)")
                self.sendAlert(message: "There has been an error while fetching the image.")
            }
            
            if let response = response, let data = data {
                let httpResponse = response as! HTTPURLResponse
                if (httpResponse.statusCode == 500) {
                    let dataString = String(data: data, encoding: String.Encoding.ascii)!
                    print(dataString)
                    self.sendAlert(message: dataString)
                } else {
                    print("Download Finished For: " + data.description)
                    DispatchQueue.main.async() {
                        self.updateViewWithImage(data)
                    }
                }
            }
            let diff = (self.info.systemUptime - self.startTime)
            print("Elapsed Time: \(diff)")
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

extension SingleImageDisplayViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            self.vSpinner?.removeFromSuperview()
            self.vSpinner = nil
        }
    }
}
