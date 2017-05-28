//
//  AudioUnitViewController.swift
//  PedalAU
//
//  Created by Lawrence Herman on 5/25/17.
//  Copyright © 2017 Lawrence Herman. All rights reserved.
//


import CoreAudioKit
import PedalFramework

extension AudioUnitViewController: AUAudioUnitFactory {
    
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try PedalAUAudioUnit(componentDescription: componentDescription, options: [])
        
        return audioUnit!
    }
    
}
