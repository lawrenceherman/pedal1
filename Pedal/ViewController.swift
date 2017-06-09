//
//  ViewController.swift
//  Pedal
//
//  Created by Lawrence Herman on 5/25/17.
//  Copyright © 2017 Lawrence Herman. All rights reserved.
//

import UIKit
import PedalFramework
import AVFoundation
import CoreAudioKit


class ViewController: UIViewController {
    
    
    
    
    var auViewController: PedalViewController!
    var containerView: UIView!
    //  var session: AVAudioSession!
    
    var audioEngine: AVAudioEngine!
    
    var sourceNode: AVAudioPlayerNode!
    var audioFile: AVAudioFile!
    var audioFileBuffer: AVAudioPCMBuffer!
    //   var componentDescription: AudioComponentDescription!
    
    
    //  from simplePlaybackEngine
    
    var testAUAudioUnit: AUAudioUnit!
    var testAVAudioUnit: AVAudioUnit!
    
    
    private var componentType = kAudioUnitType_Effect
    
    
    func clearPreviousAudioUnit () {
        
        if testAVAudioUnit != nil {
            // Break player -> effect connection.
            audioEngine.disconnectNodeInput(testAVAudioUnit)
            
            
            // Break testUnitNode -> mixer connection
            audioEngine.disconnectNodeInput(audioEngine.mainMixerNode)
            
            // We're done with the unit; release all references.
            audioEngine.detach(testAVAudioUnit)
            
            
            testAVAudioUnit = nil
            testAUAudioUnit = nil
            //                presetList = [AUAudioUnitPreset]()
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        // set up the plug in view
        embedPlugInView()
        
        // create engine and load temp file
        audioEngine = AVAudioEngine()
        
        loadTempSource()
        
        clearPreviousAudioUnit()
        
        
        var componentDescription = AudioComponentDescription()
        
        // is kAudioUnitType_Effect just an alias for 4 Byte OSType
        componentDescription.componentType = kAudioUnitType_Effect
        
        // figure out this OSType.  "Manufacturer needs to be registered with apple"
        componentDescription.componentSubType = 0x666c7472 /*fltr*/
        componentDescription.componentManufacturer = 0x44656d6f /*Demo*/
        
        // these are supposed to be set to 0
        componentDescription.componentFlags = 0
        componentDescription.componentFlagsMask = 0
        
        // whats up with version.  does name need to match .info on appex
        AUAudioUnit.registerSubclass(PedalAUAudioUnit.self, as: componentDescription, name: "Demo: PedalAU", version: UInt32.max)
        
        
        
        //        sourceNode.play()
        
        selectAudioUnitWithComponentDescription(componentDescription) {
            
            self.connectParametersToControls()
            
            //        do {
            //            try self.audioEngine.start()
            //        } catch {
            //
            //        print("could not start audioEngine")
            //
            //        }
            
            
            
        }
        
    }
    
    func embedPlugInView() {
        
        containerView = UIView()
        self.view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        
        auViewController = PedalViewController()
        
        if let view = auViewController.view {
            addChildViewController(auViewController)
            view.frame = containerView.bounds
            containerView.addSubview(view)
            auViewController.didMove(toParentViewController: self)
        }
        
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.black.cgColor
    }
    
    func connectParametersToControls() {
        
        let audioUnit = testAUAudioUnit as? PedalAUAudioUnit
        auViewController.audioUnit = audioUnit
        
        
        
        
    }
    
    
    public func selectAudioUnitWithComponentDescription(_ componentDescription: AudioComponentDescription?, completionHandler: @escaping (() -> Void)) {
        
        sourceNode = AVAudioPlayerNode()
        
        audioEngine.attach(sourceNode)
        sourceNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        
        
        let hardwareFormat = self.audioEngine.outputNode.outputFormat(forBus: 0)
        audioEngine.connect(audioEngine.mainMixerNode, to: audioEngine.outputNode, format: hardwareFormat)
        
        // Destroy any pre-existing unit.
        if testAUAudioUnit != nil {
            
            // Break player -> effect connection.
            audioEngine.disconnectNodeInput(testAVAudioUnit)
            
            
            // Break testUnitNode -> mixer connection
            audioEngine.disconnectNodeInput(audioEngine.mainMixerNode)
            
            // Connect player -> mixer.
            audioEngine.connect(sourceNode, to: audioEngine.mainMixerNode, format: audioFile.processingFormat)
            
            
            // We're done with the unit; release all references.
            audioEngine.detach(testAVAudioUnit)
            
            testAVAudioUnit = nil
            testAUAudioUnit = nil
        }
        
        // Insert the audio unit, if any.
        if let componentDescription = componentDescription {
            AVAudioUnit.instantiate(with: componentDescription, options: []) { avAudioUnit, _ in
                
                guard let avAudioUnit = avAudioUnit else { return }
                
                // Important to do this here, before the audio unit is attached
                
                self.testAUAudioUnit = avAudioUnit.auAudioUnit
                
                
                self.testAVAudioUnit = avAudioUnit
                self.audioEngine.attach(avAudioUnit)
                
                self.audioEngine.disconnectNodeInput(self.audioEngine.mainMixerNode)
                
                // Connect player -> effect -> mixer.
                self.audioEngine.connect(self.sourceNode, to: avAudioUnit, format: self.audioFile.processingFormat)
                self.audioEngine.connect(avAudioUnit, to: self.audioEngine.mainMixerNode, format: self.audioFile.processingFormat)
            }
            
            
        }
        
        completionHandler()
        
    }

    
    
    func loadTempSource() {
        
        audioFile = AVAudioFile()
        
        let path = Bundle.main.path(forResource: "DTTS 44.1", ofType: "mp3")!
        let url = URL(fileURLWithPath: path)
        audioFile = try! AVAudioFile(forReading: url)
        let audioFormat = audioFile.processingFormat
        let audioFrameCount = UInt32(audioFile.length)
        audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
        
        print("audioFileBuffer Format \(audioFileBuffer.format)\n\n")
        
        do {
            try audioFile.read(into: audioFileBuffer)
        }
        catch {
            print("error")
        }
        
    }
    
    
}

//    func setSessionCategoryMode() {
//
//        //    Instead of setting your category and mode properties independently, it's recommended that you set them at the same time using the setCategory(_:mode:options:) method.
//
//
//        do {
//            try session.setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeDefault, options: AVAudioSessionCategoryOptions.mixWithOthers)
//        }
//        catch {
//            print(error)
//        }
//    }




