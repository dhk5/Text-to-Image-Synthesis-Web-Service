//
//  Image-To-TextTests.swift
//  Text-to-Image-SynthesisTests
//
//  Created by Ryan Kang on 4/27/19.
//

import Foundation


import Foundation
import XCTest

class Image_to_TextTests: XCTestCase {
    
    var imageData1: ImageData?
    var imageData2: ImageData?
    
    override func setUp() {
        super.setUp()
        imageData1 = ImageData()
        imageData1!.image = UIImage()
        imageData1!.imageId = "imageData1"
        imageData1!.imageName = "imageData1"
        imageData2 = ImageData()
        imageData2!.image = UIImage()
        imageData2!.imageId = "imageData2"
        imageData2!.imageName = "imageData2"
    }
    
    override func tearDown() {
        super.tearDown()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testImageData() {
        let data = ImageData()
        XCTAssertNil(data.image)
        XCTAssertEqual(data.imageId, "")
        XCTAssertEqual(data.imageName, "")
        
        data.image = UIImage()
        data.imageId = "data"
        data.imageName = "data"
        
        XCTAssertNotNil(data.image)
        XCTAssertEqual(data.imageId, "data")
        XCTAssertEqual(data.imageName, "data")
    }
    
    func testImageCollectionViewController() {
        let bundle = Bundle(for: self.classForCoder)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let imageCollectionViewController = storyboard.instantiateViewController(withIdentifier: "ImageCollectionViewController") as! ImageCollectionViewController
        let _ = imageCollectionViewController.view
        
        // Test Pre-condition
        XCTAssertEqual(imageCollectionViewController.shouldReload, false)
        XCTAssertEqual(imageCollectionViewController.nextButton.isEnabled, false)
        XCTAssertEqual(imageCollectionViewController.nameIdMap.count, 3458)
        XCTAssertEqual(imageCollectionViewController.imageDataArr.count, 20)
        
        // Test refresh button
        imageCollectionViewController.arrSelectedData.append(imageData1!)
        imageCollectionViewController.arrSelectedData.append(imageData2!)
        XCTAssertEqual(imageCollectionViewController.arrSelectedData.count, 2)
        imageCollectionViewController.refreshButtonTapped()
        XCTAssertEqual(imageCollectionViewController.arrSelectedData.count, 0)
    }
    
    func testImageCreateViewController() {
        let bundle = Bundle(for: self.classForCoder)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let imageCreateViewController = storyboard.instantiateViewController(withIdentifier: "ImageCreateViewController") as! ImageCreateViewController
        
        // Add image datas
        imageCreateViewController.arrSelectedData.append(imageData1!)
        imageCreateViewController.arrSelectedData.append(imageData2!)
        
        let _ = imageCreateViewController.view
        
        // Test Pre-condition
        XCTAssertEqual(imageCreateViewController.mainNoundImageTitle, "ImageData1")
        XCTAssertEqual(imageCreateViewController.dependentNounImageTitle,"ImageData2")
        XCTAssertEqual(imageCreateViewController.imagePreposition, "Above")
        XCTAssertEqual(imageCreateViewController.generateButton.isEnabled, false)
        
        // Generate text button tapped
        imageCreateViewController.calculateDistance()
        XCTAssertEqual(imageCreateViewController.generateButton.isEnabled, true)
        imageCreateViewController.generateButtonTapped()
        XCTAssertEqual(imageCreateViewController.imageDescriptionLabel.text, "ImageData1 Above ImageData2")
        
        // Over
        imageCreateViewController.dependentNounImageView.center.x = 0
        imageCreateViewController.dependentNounImageView.center.y = 0
        imageCreateViewController.mainNounImageView.center.x = 0
        imageCreateViewController.mainNounImageView.center.y = 0
        imageCreateViewController.calculateDistance()
        imageCreateViewController.generateButtonTapped()
        XCTAssertEqual(imageCreateViewController.imageDescriptionLabel.text, "ImageData1 Over ImageData2")
        
        // On
        imageCreateViewController.dependentNounImageView.center.x = 0
        imageCreateViewController.dependentNounImageView.center.y = 150
        imageCreateViewController.mainNounImageView.center.x = 0
        imageCreateViewController.mainNounImageView.center.y = 0
        imageCreateViewController.calculateDistance()
        imageCreateViewController.generateButtonTapped()
        XCTAssertEqual(imageCreateViewController.imageDescriptionLabel.text, "ImageData1 On ImageData2")
        
        // Under
        imageCreateViewController.dependentNounImageView.center.x = 0
        imageCreateViewController.dependentNounImageView.center.y = 0
        imageCreateViewController.mainNounImageView.center.x = 0
        imageCreateViewController.mainNounImageView.center.y = 150
        imageCreateViewController.calculateDistance()
        imageCreateViewController.generateButtonTapped()
        XCTAssertEqual(imageCreateViewController.imageDescriptionLabel.text, "ImageData1 Under ImageData2")
        
        // Above
        imageCreateViewController.dependentNounImageView.center.x = 0
        imageCreateViewController.dependentNounImageView.center.y = 250
        imageCreateViewController.mainNounImageView.center.x = 0
        imageCreateViewController.mainNounImageView.center.y = 0
        imageCreateViewController.calculateDistance()
        imageCreateViewController.generateButtonTapped()
        XCTAssertEqual(imageCreateViewController.imageDescriptionLabel.text, "ImageData1 Above ImageData2")
        
        // Below
        imageCreateViewController.dependentNounImageView.center.x = 0
        imageCreateViewController.dependentNounImageView.center.y = 0
        imageCreateViewController.mainNounImageView.center.x = 0
        imageCreateViewController.mainNounImageView.center.y = 250
        imageCreateViewController.calculateDistance()
        imageCreateViewController.generateButtonTapped()
        XCTAssertEqual(imageCreateViewController.imageDescriptionLabel.text, "ImageData1 Below ImageData2")
        
        // Near
        imageCreateViewController.dependentNounImageView.center.x = 50
        imageCreateViewController.dependentNounImageView.center.y = 50
        imageCreateViewController.mainNounImageView.center.x = 0
        imageCreateViewController.mainNounImageView.center.y = 0
        imageCreateViewController.calculateDistance()
        imageCreateViewController.generateButtonTapped()
        XCTAssertEqual(imageCreateViewController.imageDescriptionLabel.text, "ImageData1 Near ImageData2")
    }
}
