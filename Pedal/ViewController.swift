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


class ViewController: UIViewController {
    

    var auViewController: AudioUnitViewController!
    var containerView: UIView!
//    var avAudioUnit = AVAudioUnit()
    
    
    var audioEngine: AVAudioEngine!
    var sourceNode: AVAudioPlayerNode!
    var audioFile: AVAudioFile!
    var audioFileBuffer: AVAudioPCMBuffer!
    var componentDescription: AudioComponentDescription!
    
    var testAudioUnit: AUAudioUnit?
    var testUnitNode: AVAudioUnit?
//    var session: AVAudioSession!
    
 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        embedPlugInView()
        loadTempSource()
        
        componentDescription = AudioComponentDescription()
        
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
        
        loadAudioEngine()
        
        try! audioEngine.start()
   
        
//        sourceNode.play()
        
        
        
    }

    func embedPlugInView() {
        
        containerView = UIView()
        self.view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        
        auViewController = AudioUnitViewController()
        
        if let view = auViewController.view {
            addChildViewController(auViewController)
            view.frame = containerView.bounds
            
            containerView.addSubview(view)
            auViewController.didMove(toParentViewController: self)
        }
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
    
    func loadAudioEngine() {
    
        audioEngine = AVAudioEngine()
        sourceNode = AVAudioPlayerNode()
        
        audioEngine.attach(sourceNode)
        sourceNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        
        let hardwareFormat = self.audioEngine.outputNode.outputFormat(forBus: 0)
        
        print("outputNode output \(hardwareFormat)\n\n")
        
        self.audioEngine.connect(self.audioEngine.mainMixerNode, to: self.audioEngine.outputNode, format: hardwareFormat)
        
        
        print("main mixer node input \(audioEngine.mainMixerNode.inputFormat(forBus: 0))\n\n")
        
        print("main mixer node output \(audioEngine.mainMixerNode.outputFormat(forBus:0))\n\n")
        
        AVAudioUnit.instantiate(with: self.componentDescription, options: .loadOutOfProcess) {
            (avAudioUnit, error) in
            
            guard let avAudioUnit = avAudioUnit else { return }
            
            
        
            self.testUnitNode = avAudioUnit
        
            self.audioEngine.attach(avAudioUnit)
            
            
            print(avAudioUnit.numberOfOutputs)
            print(avAudioUnit.numberOfInputs)
            print(avAudioUnit.manufacturerName)
            print(avAudioUnit.auAudioUnit.audioUnitName)
            
//            self.audioEngine.connect(self.sourceNode, to: self.audioEngine.mainMixerNode, format: self.audioFile.processingFormat)
            
            self.audioEngine.connect(self.sourceNode, to: avAudioUnit, format: self.audioFile.processingFormat)

            self.audioEngine.connect(avAudioUnit, to: self.audioEngine.mainMixerNode, format: self.audioFile.processingFormat)

            self.testAudioUnit = avAudioUnit.auAudioUnit
            
            let audioUnit = self.testAudioUnit! as! PedalAUAudioUnit
            self.auViewController.audioUnit = audioUnit
        
        
        
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



}

