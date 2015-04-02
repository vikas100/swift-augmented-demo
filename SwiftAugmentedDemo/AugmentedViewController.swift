//
//  ViewController.swift
//  SwiftAugmentedDemo
//
//  Created by Joel Teply on 3/27/15.
//  Copyright (c) 2015 Joel Teply. All rights reserved.
//

import UIKit
import AVFoundation

class AugmentedViewController: UIViewController, CBVideoDeviceDelegate {
    
    var videoPainter: CBVideoPainter!
    
    @IBOutlet weak var augmentedView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        //iniitialize a new instance of video painter
        videoPainter = CBVideoPainter(cameraAtPosition: AVCaptureDevicePosition.Back, delegate: self)
        
        //set its output to the view where we want it displayed
        videoPainter.output = augmentedView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        //start running the augmented reality
        videoPainter.startRunning()
    }
    
    //when clicked, clear all points currently selected
    @IBAction func clearPointsClicked(sender: AnyObject) {
        videoPainter.clearPaintPoints()
    }
    
}

