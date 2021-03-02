//
//  PlaySoundsViewController+Audio.swift
//  PitchPerfect
//
//  Copyright © 2016 Udacity. All rights reserved.
//  Modified by Antonio Isasi Varela on 20/02/2021.
//

import UIKit
import AVFoundation

/// An extension of the PlaySoundsViewController class (a view controller for audio playing)
extension PlaySoundsViewController: AVAudioPlayerDelegate {
    
    /// UI alert messages
    struct Alerts {
        static let DismissAlert = "Dismiss"
        static let RecordingDisabledTitle = "Recording Disabled"
        static let RecordingDisabledMessage = "You've disabled this app from recording your microphone. Check Settings."
        static let RecordingFailedTitle = "Recording Failed"
        static let RecordingFailedMessage = "Something went wrong with your recording."
        static let AudioRecorderError = "Audio Recorder Error"
        static let AudioSessionError = "Audio Session Error"
        static let AudioRecordingError = "Audio Recording Error"
        static let AudioFileError = "Audio File Error"
        static let AudioEngineError = "Audio Engine Error"
    }
    
    /// A list of possible playing states (i.e. playing or not playing)
    enum PlayingState { case playing, notPlaying }
    
    // MARK: Audio methods
    
    /// Initializes the audio file that will be played
    func setupAudio() {
        do {
            audioFile = try AVAudioFile(forReading: recordedAudioURL as URL)
        } catch {
            showAlert(Alerts.AudioFileError, message: String(describing: error))
        }        
    }
    
    /**
     Plays audio with a particular effect (determined by the parameters).
     
     - Parameters:
         - rate: The speed rate at which audio is played.
         - pitch: The pitch rate at which audio is played.
         - echo: `true` if audio is played with an echo effect, `false` if not.
         - reverb: `true` if audio is played with a reverb effect, `false` if not.
     
     */
    func playSound(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false) {
        
        // initialize audio engine components
        audioEngine = AVAudioEngine()
        
        // node for playing audio
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        // node for adjusting rate/pitch
        let changeRatePitchNode = AVAudioUnitTimePitch()
        if let pitch = pitch {
            changeRatePitchNode.pitch = pitch
        }
        if let rate = rate {
            changeRatePitchNode.rate = rate
        }
        audioEngine.attach(changeRatePitchNode)
        
        // node for echo
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        audioEngine.attach(echoNode)
        
        // node for reverb
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 50
        audioEngine.attach(reverbNode)
        
        // connect nodes
        if echo == true && reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
        } else if echo == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
        } else if reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
        } else {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
        }
        
        // schedule to play and start the engine!
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, at: nil) {
            
            var delayInSeconds: Double = 0
            
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
                
                if let rate = rate {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
                } else {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                }
            }
            
            // schedule a stop timer for when audio finishes playing
            self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(PlaySoundsViewController.stopAudio), userInfo: nil, repeats: false)
            RunLoop.main.add(self.stopTimer!, forMode: RunLoop.Mode.default)
        }
        
        do {
            try audioEngine.start()
        } catch {
            showAlert(Alerts.AudioEngineError, message: String(describing: error))
            return
        }
        
        // play the recording!
        audioPlayerNode.play()
    }
    
    /// Stops the audio that is being played
    @objc func stopAudio() {
        
        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }
        
        if let stopTimer = stopTimer {
            stopTimer.invalidate()
        }
        
        configureUI(.notPlaying)
        
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
    }
    
    /**
     Connects all the audio nodes by using the audio engine.
     
     - Parameter nodes: Nodes to be connected.
     
     */
    func connectAudioNodes(_ nodes: AVAudioNode...) {
        for x in 0..<nodes.count-1 {
            audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
        }
    }
    
    // MARK: UI functions
    
    /**
     Configures the UI depending on whether audio is being played or not.
     
     - Parameter playState: The playing state (i.e. playing or not playing).
     
     */
    func configureUI(_ playState: PlayingState) {
        switch(playState) {
        case .playing:
            setPlayButtonsEnabled(false)
            stopButton.isEnabled = true
        case .notPlaying:
            setPlayButtonsEnabled(true)
            stopButton.isEnabled = false
        }
        setupButtons()
    }
    
    /**
     Enables or disables all playing buttons.
     
     - Parameter enabled: `true` if buttons are enabled, `false` if buttons are disabled.
     
     */
    func setPlayButtonsEnabled(_ enabled: Bool) {
        slowButton.isEnabled = enabled
        highPitchButton.isEnabled = enabled
        fastButton.isEnabled = enabled
        lowPitchButton.isEnabled = enabled
        echoButton.isEnabled = enabled
        reverbButton.isEnabled = enabled
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
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Scales image buttons so that they are properly displayed on the screen
    func setupButtons() {
        scaleButton(slowButton)
        scaleButton(fastButton)
        scaleButton(lowPitchButton)
        scaleButton(highPitchButton)
        scaleButton(echoButton)
        scaleButton(reverbButton)
        scaleButton(stopButton)
    }
    
    /**
     Scales an image button by setting its content mode to  `scaleAspectFit`.
     
     - Parameter button: The UIButton to be scaled.
     
     */
    func scaleButton(_ button: UIButton) {
        button.imageView?.contentMode = .scaleAspectFit
    }
}
