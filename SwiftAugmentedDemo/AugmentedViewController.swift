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
    var savedPainterImage: CBImagePainterImage!
    let kVideoToImageSegueIdentifier = "StillViewSegue"
    var gotoStillView = false
    
    @IBOutlet weak var augmentedView: UIView!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var stillPainter: CBImagePainter!
    
    @IBOutlet weak var zoomMenu: UIToolbar!
    @IBOutlet weak var zoomStartStopPaintingButton: UIBarButtonItem!
    @IBOutlet weak var zoomOutButton: UIBarButtonItem!
    
    @IBAction func startStopScrollingClicked(sender: AnyObject) {
        self.stillPainter.touchPaintEnabled = !self.stillPainter.touchPaintEnabled
        
        setZoomMenuTexts()
    }
    
    @IBAction func zoomOutButtonClicked(sender: AnyObject) {
        self.stillPainter.zoomOut()
    }
    
    deinit {
        // perform the deinitialization
        println("deinit AugmentedViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //iniitialize a new instance of video painter
        videoPainter = CBVideoPainter(cameraAtPosition: AVCaptureDevicePosition.Back, delegate: self)
        
        self.zoomMenu.hidden = true
        setZoomMenuTexts()
        
        stillPainter.zoomingCompletedBlock = ({[weak self] in
            if let strongSelf = self {
                strongSelf.zoomMenu.hidden = (strongSelf.stillPainter.zoomScale == 1.0)
                strongSelf.setZoomMenuTexts()
            }
        })
        
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
        stillPainter.clearAll()
    }
    
    @IBAction func startStopClicked(sender: AnyObject) {
        
        startStopAugmentedReality(!videoPainter.isRunning)
    }
    
    func startStopAugmentedReality(start:Bool) {
        if (start) {
            self.stillPainter.hidden = true
            startStopButton.setTitle("Stop", forState: UIControlState.Normal)
            videoPainter.startRunning()
        }
        else {
            self.stillPainter.hidden = true
            startStopButton.setTitle("Resume", forState: UIControlState.Normal)
            videoPainter.stopRunning()
        }
    }
    
    //when clicked, clear all points currently selected
    @IBAction func captureClicked(sender: AnyObject) {
        
        if (gotoStillView) {
            self.videoPainter.captureCurrentState({(imageWithMask: CBImagePainterImage!) -> Void in
                self.savedPainterImage = imageWithMask
                self.startStopAugmentedReality(false)
                self.performSegueWithIdentifier(self.kVideoToImageSegueIdentifier, sender: self)
            })
        } else {
            self.videoPainter.captureCurrentState(self.stillPainter, completed: { () -> Void in
                self.startStopAugmentedReality(false)
                self.stillPainter.hidden = false
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kVideoToImageSegueIdentifier {
            var imagePaintViewController = segue.destinationViewController as! StillViewController
            imagePaintViewController.imageToLoad = self.savedPainterImage
        }
    }
    
    func setZoomMenuTexts() {
        if (self.stillPainter.touchPaintEnabled) {
            self.zoomStartStopPaintingButton.title = "Enable Scrolling"
        }
        else {
            self.zoomStartStopPaintingButton.title = "Switch to Painting"
        }
    }
    
}

