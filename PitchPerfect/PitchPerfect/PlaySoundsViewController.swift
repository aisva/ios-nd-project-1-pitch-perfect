//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by Antonio Isasi Varela on 18/2/21.
//

import UIKit
import AVFoundation

/// View controller for audio playing
final internal class PlaySoundsViewController: UIViewController {
    
    /// A button for playing audio slowly
    @IBOutlet weak var slowButton: UIButton!
    /// A button for playing audio fast
    @IBOutlet weak var fastButton: UIButton!
    /// A button for playing audio with a high pitch effect
    @IBOutlet weak var highPitchButton: UIButton!
    /// A button for playing audio with a low pitch effect
    @IBOutlet weak var lowPitchButton: UIButton!
    /// A button for playing audio with an echo effect
    @IBOutlet weak var echoButton: UIButton!
    /// A button for playing audio with a reverb effect
    @IBOutlet weak var reverbButton: UIButton!
    /// A button for stopping the audio that is being played
    @IBOutlet weak var stopButton: UIButton!
    
    /// The URL of the audio that will be played
    var recordedAudioURL:URL!
    /// The recorded audio file that will be played
    var audioFile:AVAudioFile!
    /// The audio engined needed to connect the different audio nodes
    var audioEngine:AVAudioEngine!
    /// The audio node for the recorded audio
    var audioPlayerNode: AVAudioPlayerNode!
    /// A timer used for stopping the audio that is being played
    var stopTimer: Timer!
    
    /// A list of all the possible button types for playing audio with different effects
    enum ButtonType: Int {
        case slow = 0, fast, chipmunk, vader, echo, reverb
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAudio()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureUI(.notPlaying)
    }
    
    /**
     Plays audio with a particular effect (determined by the `sender`).
     
     - Parameter sender: The UIButton that calls this method.
     
     */
    @IBAction func playSoundForButton(_ sender: UIButton) {
        switch(ButtonType(rawValue: sender.tag)!) {
        case .slow:
            playSound(rate: 0.5)
        case .fast:
            playSound(rate: 1.5)
        case .chipmunk:
            playSound(pitch: 1000)
        case .vader:
            playSound(pitch: -1000)
        case .echo:
            playSound(echo: true)
        case .reverb:
            playSound(reverb: true)
        }
        
        configureUI(.playing)
    }
    
    /**
     Stops the audio that is being played.
     
     - Parameter sender: The UIButton that calls this method.
     
     */
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        stopAudio()
    }
}
