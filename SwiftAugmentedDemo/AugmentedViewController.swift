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

        videoPainter = CBVideoPainter(cameraAtPosition: AVCaptureDevicePosition.Back, delegate: self)
        
        videoPainter.output = augmentedView
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        videoPainter.startRunning()
    }
    
    @IBAction func clearPointsClicked(sender: AnyObject) {
        videoPainter.clearPaintPoints()
    }
    
}

