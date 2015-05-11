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

    @IBOutlet weak var startStopButton: UIButton!
    
    deinit {
        // perform the deinitialization
        println("deinit AugmentedViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //iniitialize a new instance of video painter
        videoPainter = CBVideoPainter(cameraAtPosition: AVCaptureDevicePosition.Back, delegate: self)
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        augmentedView.frame = self.view.frame
        //set its output to the view where we want it displayed
        videoPainter.output = augmentedView
        
        //start running the augmented reality
        videoPainter.startRunning()
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        videoPainter.stopRunning()
        
    }
    
    //when clicked, clear all points currently selected
    @IBAction func clearPointsClicked(sender: AnyObject) {
        videoPainter.clearPaintPoints()
    }
    
    @IBAction func stopAugmentedReality(sender: AnyObject) {
        if (videoPainter.isRunning) {
            startStopButton.setTitle("Start Running", forState: UIControlState.Normal)
            videoPainter.stopRunning()
        } else {
            startStopButton.setTitle("Stop Running", forState: UIControlState.Normal)
            videoPainter.startRunning()
        }
    }
}

