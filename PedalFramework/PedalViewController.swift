//
//  AudioUnitViewController.swift
//  Pedal
//
//  Created by Lawrence Herman on 5/25/17.
//  Copyright © 2017 Lawrence Herman. All rights reserved.
//

import UIKit
import CoreAudioKit

public class PedalViewController: AUViewController {
    
    public var audioUnit: PedalAUAudioUnit? {
        didSet {
            
            
            
//            
//            DispatchQueue.main.async {
//                if self.isViewLoaded{
//                    self.connectViewWithAU()
//                }
//            }
            
            print("AudioUnitViewControllerwasset")
            
        }
        
        
        
    }
    
    func connectViewWithAU() {
        
        
        
        
    }
    

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let cgrect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let tempLabel = UILabel(frame: cgrect)
        self.view.addSubview(tempLabel)
        tempLabel.textColor = UIColor.white
        tempLabel.text = "Hello"
        
        
        
        if audioUnit == nil {
            print("inside AudioUnitViewController audiounit is nil\n\n")
        
        } else {
            print("inside AudioUnitViewController audiounit is not nil \n\n")
        }
        
        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
    
    }
    
}
