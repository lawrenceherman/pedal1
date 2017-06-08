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
    
    
    var audioEngine = AVAudioEngine()
    var sourceNode = AVAudioPlayerNode()
    var audioFile: AVAudioFile!
    var audioFileBuffer: AVAudioPCMBuffer!
    var componentDescription: AudioComponentDescription!
    
    var testAUAudioUnit: AUAudioUnit!
    var testAVAudioUnit: AVAudioUnit!
//    var session: AVAudioSession!
    
 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // Listen for orientation changes  from newest av3 sample
//        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.orientationChanged),
//                                               name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        
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
        
        
        auViewController = AudioUnitViewController() as! AudioUnitViewController
        
        
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
    
//        audioEngine = AVAudioEngine()
//        sourceNode = AVAudioPlayerNode()
        
        audioEngine.attach(sourceNode)
        sourceNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        
//        let hardwareFormat = self.audioEngine.outputNode.outputFormat(forBus: 0)
        
 //       print("outputNode output \(hardwareFormat)\n\n")
        
//        self.audioEngine.connect(self.audioEngine.mainMixerNode, to: self.audioEngine.outputNode, format: hardwareFormat)
        
        
        print("main mixer node input \(audioEngine.mainMixerNode.inputFormat(forBus: 0))\n\n")
        
        print("main mixer node output \(audioEngine.mainMixerNode.outputFormat(forBus:0))\n\n")
        
        
        

        
        AVAudioUnit.instantiate(with: self.componentDescription, options: []) {
           [unowned self ](avAudioUnit, error) in
            
            guard let avAudioUnit = avAudioUnit else { return }
            
            
        
            self.testAUAudioUnit = avAudioUnit.auAudioUnit
            self.testAVAudioUnit = avAudioUnit
            self.audioEngine.attach(self.testAVAudioUnit)


            let audioUnit = self.testAUAudioUnit as? PedalAUAudioUnit
            self.auViewController.audioUnit = audioUnit
            
            
//            print(avAudioUnit.numberOfOutputs)
//            print(avAudioUnit.numberOfInputs)
//            print(avAudioUnit.manufacturerName)
        
//            print(avAudioUnit.auAudioUnit.audioUnitName)
            
            
            
//            self.audioEngine.connect(self.sourceNode, to: avAudioUnit, format: self.audioFile.processingFormat)
//
//            self.audioEngine.connect(avAudioUnit, to: self.audioEngine.mainMixerNode, format: self.audioFile.processingFormat)
            
//            self.audioEngine.connect(self.sourceNode, to: self.audioEngine.mainMixerNode, format: self.audioFile.processingFormat)
            
            self.audioEngine.connect(self.sourceNode, to: self.testAVAudioUnit, format: self.audioFile.processingFormat)
            
            self.audioEngine.connect(self.testAVAudioUnit, to: self.audioEngine.mainMixerNode, format: self.audioFile.processingFormat)
            
            do {
                
                try self.audioEngine.start()
                
            } catch {
                
                print("could not start audioEngine")
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
    
    public func selectAudioUnitWithComponentDescription(_ componentDescription: AudioComponentDescription?, completionHandler: @escaping (() -> Void)) {
        // Internal function to resume playing and call the completion handler.
//        func done() {
//            if isEffect() && isPlaying {
//                player.play()
//            } else if isInstrument() && isPlaying {
//                instrumentPlayer = InstrumentPlayer(audioUnit: testAudioUnit)
//                instrumentPlayer?.play()
//            }
//            
//            completionHandler()
//        }
        
        let hardwareFormat = self.engine.outputNode.outputFormat(forBus: 0)
        
        self.engine.connect(self.engine.mainMixerNode, to: self.engine.outputNode, format: hardwareFormat)
        
        /*
         Pause the player before re-wiring it. (It is not simple to keep it
         playing across an insertion or deletion.)
         */
//        if isEffect() && isPlaying {
//            player.pause()
//        } else if isInstrument() && isPlaying {
//            instrumentPlayer?.stop()
//            instrumentPlayer = nil
//        }
        
        // Destroy any pre-existing unit.
        if testAUAudioUnit != nil {
            if isEffect() {
                // Break player -> effect connection.
                engine.disconnectNodeInput(testUnitNode!)
            }
            
            // Break testUnitNode -> mixer connection
            engine.disconnectNodeInput(engine.mainMixerNode)
            
            if isEffect() {
                // Connect player -> mixer.
                engine.connect(player, to: engine.mainMixerNode, format: file!.processingFormat)
            }
            
            // We're done with the unit; release all references.
            engine.detach(testUnitNode!)
            
            testUnitNode = nil
            testAudioUnit = nil
            presetList = [AUAudioUnitPreset]()
        }
        
        // Insert the audio unit, if any.
        if let componentDescription = componentDescription {
            AVAudioUnit.instantiate(with: componentDescription, options: instantiationOptions) { avAudioUnit, _ in
                guard let avAudioUnit = avAudioUnit else { return }
                
                // Important to do this here, before the audio unit is attached
                self.testAudioUnit = avAudioUnit.auAudioUnit
                if (self.testAudioUnit!.midiOutputNames.count > 0) {
                    self.testAudioUnit!.midiOutputEventBlock = self.midiOutBlock
                }
                
                self.testUnitNode = avAudioUnit
                self.engine.attach(avAudioUnit)
                
                if self.isEffect() {
                    // Disconnect player -> mixer.
                    self.engine.disconnectNodeInput(self.engine.mainMixerNode)
                    
                    // Connect player -> effect -> mixer.
                    self.engine.connect(self.player, to: avAudioUnit, format: self.file!.processingFormat)
                    self.engine.connect(avAudioUnit, to: self.engine.mainMixerNode, format: self.file!.processingFormat)
                } else {
                    let stereoFormat = AVAudioFormat(standardFormatWithSampleRate: hardwareFormat.sampleRate, channels: 2)
                    self.engine.connect(avAudioUnit, to: self.engine.mainMixerNode, format: stereoFormat)
                }
                
                self.presetList = avAudioUnit.auAudioUnit.factoryPresets ?? []
                avAudioUnit.auAudioUnit.contextName = "Sample code AUv3Host"
                done()
            }
        } else {
            done()
        }
    }
}




}

