//
//  ViewController.swift
//  Pedal
//
//  Created by Lawrence Herman on 5/25/17.
//  Copyright © 2017 Lawrence Herman. All rights reserved.
//

import UIKit
import PedalFramework


class ViewController: UIViewController {
    

    @IBOutlet weak var auContainerView: UIView!
    
    var auViewController: AudioUnitViewController!
    

 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let builtInPlugInsURL = Bundle.main.builtInPlugInsURL!
        let pluginURL = builtInPlugInsURL.appendingPathComponent("PedalAU.appex")
        let appExtensionBundle = Bundle(url: pluginURL)
        
        
        let storyboard = UIStoryboard(name: "MainInterface", bundle: appExtensionBundle)
        
        
//        auViewController = storyboard.instantiateViewController(withIdentifier: "AudioUnitViewController") as! AudioUnitViewController
        


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

