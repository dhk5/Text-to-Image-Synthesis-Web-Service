//
//  Text-to-ImageTests.swift
//  Text-to-Image-SynthesisTests
//
//  Created by Ryan Kang on 4/27/19.
//

import Foundation
import XCTest

class Text_to_ImageTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        super.tearDown()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSpeechDetectionViewController() {
        let bundle = Bundle(for: self.classForCoder)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let speechDetectionViewController = storyboard.instantiateViewController(withIdentifier: "SpeechDetectionViewController") as! SpeechDetectionViewController
        let _ = speechDetectionViewController.view
        
        XCTAssertEqual(speechDetectionViewController.detectedTextLabel.text, "")
        XCTAssertEqual(speechDetectionViewController.startButton.isEnabled, true)
        
        // Test Pre-condition
        XCTAssertEqual(speechDetectionViewController.isRecording, false)
        XCTAssertEqual(speechDetectionViewController.startButton.titleLabel?.text, "START")
        XCTAssertEqual(speechDetectionViewController.nextButton.isEnabled, false)
        
        // Test recording started
        speechDetectionViewController.startButtonTapped()
        XCTAssertEqual(speechDetectionViewController.isRecording, true)
        XCTAssertEqual(speechDetectionViewController.startButton.currentTitle, "STOP")
        XCTAssertEqual(speechDetectionViewController.nextButton.isEnabled, false)
        speechDetectionViewController.detectedTextLabel.text = "cat on the bed"
        
        // Test recording stopped
        speechDetectionViewController.startButtonTapped()
        XCTAssertEqual(speechDetectionViewController.isRecording, false)
        XCTAssertEqual(speechDetectionViewController.startButton.currentTitle, "START")
        XCTAssertEqual(speechDetectionViewController.nextButton.isEnabled, true)
    }
    
    func testSingleImageDisplayViewController() {
        let bundle = Bundle(for: self.classForCoder)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let singleImageDisplayViewController = storyboard.instantiateViewController(withIdentifier: "SingleImageDisplayViewController") as! SingleImageDisplayViewController
        singleImageDisplayViewController.voiceCommandText = "cat on the bed"
        let _ = singleImageDisplayViewController.view
        
        XCTAssertEqual(singleImageDisplayViewController.voiceCommandText, "cat on the bed")
    }
    
    func testIsKnownPrepositionInCommandStringReturnTrueForKnownPrepositions() {
        XCTAssertTrue(SingleImageDisplayViewController.isKnownPrepositionInCommandString("on"))
        XCTAssertTrue(SingleImageDisplayViewController.isKnownPrepositionInCommandString("under"))
        XCTAssertTrue(SingleImageDisplayViewController.isKnownPrepositionInCommandString("above"))
        XCTAssertTrue(SingleImageDisplayViewController.isKnownPrepositionInCommandString("below"))
        XCTAssertTrue(SingleImageDisplayViewController.isKnownPrepositionInCommandString("near"))
    }
    
    func testIsKnownPrepositionInCommandStringReturnFalseForUnKnownPrepositions() {
        XCTAssertFalse(SingleImageDisplayViewController.isKnownPrepositionInCommandString("between"))
        XCTAssertFalse(SingleImageDisplayViewController.isKnownPrepositionInCommandString("over"))
        XCTAssertFalse(SingleImageDisplayViewController.isKnownPrepositionInCommandString("next to"))
    }
    
    func testIsKnownPrepositionInCommandStringReturnFalseForCommandStringWithWordsThatContainsPrepositions() {
        XCTAssertFalse(SingleImageDisplayViewController.isKnownPrepositionInCommandString("ion"))
        XCTAssertFalse(SingleImageDisplayViewController.isKnownPrepositionInCommandString("dunder"))
        XCTAssertFalse(SingleImageDisplayViewController.isKnownPrepositionInCommandString("fabove"))
        XCTAssertFalse(SingleImageDisplayViewController.isKnownPrepositionInCommandString("xbelow"))
        XCTAssertFalse(SingleImageDisplayViewController.isKnownPrepositionInCommandString("anear"))
    }
    
    
}
