//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Antonio Isasi Varela on 14/02/2021.
//

import UIKit
import AVFoundation

/// View controller for audio recording
final internal class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    /// The audio recorder
    var audioRecorder: AVAudioRecorder!
    
    /// A button for starting the recording
    @IBOutlet weak var recordButton: UIButton!
    /// A button for stopping the recording
    @IBOutlet weak var stopRecordingButton: UIButton!
    /// A label for displaying the recording status
    @IBOutlet weak var recordingLabel: UILabel!
    
    /// UI alert messages
    struct Alerts {
        static let DismissAlert = "Dismiss"
        static let RecordingFailedTitle = "Recording Failed"
        static let RecordingFailedMessage = "Something went wrong with your recording."
    }
    
    /// UI label messages
    struct Labels {
        static let TapToRecord = "Tap to Record"
        static let RecordingInProgress = "Recording in Progress"
    }
    
    /// View identifiers
    struct Identifiers {
        static let StopRecording = "stopRecording"
    }
    
    /// File system names (name.extension)
    struct FileNames {
        static let Recording = "recordedVoice.wav"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI(isRecording: false)
    }
    
    /**
     Starts audio recording.
     
     - Parameter sender: The UIButton that calls this method.
     
     */
    @IBAction func recordAudio(_ sender: UIButton) {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = FileNames.Recording
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
        configureUI(isRecording: true)
    }
    
    /**
     Stops audio recording.
     
     - Parameter sender: The UIButton that calls this method.
     
     */
    @IBAction func stopRecording(_ sender: UIButton) {
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
        
        configureUI(isRecording: false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: Identifiers.StopRecording, sender: audioRecorder.url)
        } else {
            showAlert(Alerts.RecordingFailedTitle, message: Alerts.RecordingFailedMessage)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.StopRecording {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
    /**
     Configures the UI depending on whether audio is being recorded or not.
     
     - Parameter isRecording: `true` if audio is being recorded, `false` if not.
     
     */
    func configureUI(isRecording: Bool) {
        recordButton.isEnabled = !isRecording
        stopRecordingButton.isEnabled = isRecording
        recordingLabel.text = isRecording ? Labels.RecordingInProgress : Labels.TapToRecord
    }
    
    /**
     Shows a UIAlertController.
     
     - Parameters:
        - title: The title of the UIAlertController.
        - message: The message of the UIAlertController.
     
     */
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
