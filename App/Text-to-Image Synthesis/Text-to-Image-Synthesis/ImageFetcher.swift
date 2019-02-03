//
//  ImageFetcher.swift
//  Text-to-Image-Synthesis
//
//  Created by Ryan Kang on 1/13/19.
//

import Foundation

class ImageFetcher {
    private let getTextToImageUrlPath = "http://localhost:3000/generateImage?text="
    private let getRandomImageUrlPath = "http://localhost:3000/getImage?id="
    
    func fetchImageWithText(commandText: String, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        let urlString = commandText.replacingOccurrences(of: " ", with: "%20")
        guard let url: URL = URL(string: "\(getTextToImageUrlPath)\(urlString)") else {
            print("Failed to create an url with command text: \(commandText)")
            completion(nil, nil, NSError(domain: ErrorDomain,
                                         code: ErrorCode.invalidUrl.rawValue,
                                         userInfo: ["errorMessage": "Error creating url"]))
            return
        }
        
        print("Fetch image with url: \(url.absoluteString)")
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func fetchRandomImage(imageID: String, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        guard let url: URL = URL(string:  "\(getRandomImageUrlPath)\(imageID)") else {
            print("Failed to create an url with command text: \(getRandomImageUrlPath)")
            completion(nil, nil, NSError(domain: ErrorDomain,
                                         code: ErrorCode.invalidUrl.rawValue,
                                         userInfo: ["errorMessage": "Error creating url"]))
            return
        }
        
        print("Fetch image with url: \(url.absoluteString)")
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
