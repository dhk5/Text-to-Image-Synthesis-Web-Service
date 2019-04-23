//
//  SpeechDetectionViewController.swift
//  Speech-Recognition-Demo
//
//  Created by Ryan Kang on 3/3/17.
//

import UIKit
import Speech

class SpeechDetectionViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var detectedTextLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestSpeechAuthorization()
    }
    
    //MARK: IBActions and Cancel
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if isRecording == true {
            self.audioEngine.inputNode.removeTap(onBus: 0)
            self.audioEngine.stop()
            self.recognitionTask?.cancel()
            self.isRecording = false
            self.startButton.setTitle("START", for: UIControl.State.normal)
            self.startButton.backgroundColor = UIColor.lightGray
            if self.detectedTextLabel.text != "" {
                nextButton.isEnabled = true
            }
        } else {
            self.recordAndRecognizeSpeech()
            self.isRecording = true
            self.startButton.setTitle("STOP", for: UIControl.State.normal)
            self.startButton.backgroundColor = UIColor.red
            self.detectedTextLabel.text = ""
            nextButton.isEnabled = false
        }
    }
    
    private func cancelRecording() {
        self.audioEngine.stop()
        let node = self.audioEngine.inputNode
        node.removeTap(onBus: 0)
        self.recognitionTask?.cancel()
    }
    
    //MARK: - Recognize Speech
    private func recordAndRecognizeSpeech() {
        let node = self.audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        self.audioEngine.prepare()
        do {
            try self.audioEngine.start()
        } catch {
            self.sendAlert(message: "There has been an audio engine error.")
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            self.sendAlert(message: "Speech recognition is not supported for your current locale.")
            return
        }
        if !myRecognizer.isAvailable {
            self.sendAlert(message: "Speech recognition is not currently available. Check back at a later time.")
            // Recognizer is not available right now.
            return
        }
        self.recognitionTask = self.speechRecognizer?.recognitionTask(with: self.request, resultHandler: { result, error in
            if result != nil {
                if let result = result {
                    // Update the detectedTextLabel with the text converted from speech.
                    let bestString = result.bestTranscription.formattedString
                    self.detectedTextLabel.text = bestString
                    
                } else if let error = error {
                    self.sendAlert(message: "There has been a speech recognition error.")
                    print(error)
                }
            }
        })
    }
    
    //MARK: - Check Authorization Status
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.startButton.isEnabled = true
                case .denied:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "User denied access to speech recognition"
                case .restricted:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "Speech recognition restricted on this device"
                case .notDetermined:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "Speech recognition not yet authorized"
                }
            }
        }
    }
    
    //MARK: - Alert
    private func sendAlert(message: String) {
        let alert = UIAlertController(title: "Speech Recognizer Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is SingleImageDisplayViewController
        {
            let vc = segue.destination as? SingleImageDisplayViewController
            vc?.voiceCommandText = self.detectedTextLabel.text!
        }
    }
}
