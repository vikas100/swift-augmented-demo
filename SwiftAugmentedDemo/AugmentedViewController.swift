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
    var gotoStillView = true
    
    @IBOutlet weak var augmentedView: UIView!
    @IBOutlet weak var stillPainter: CBImagePainter!
    
    @IBOutlet weak var zoomMenu: UIToolbar!
    @IBOutlet weak var zoomStartStopPaintingButton: UIBarButtonItem!
    @IBOutlet weak var zoomOutButton: UIBarButtonItem!
    
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var captureButton: UIBarButtonItem!
    @IBOutlet weak var currentColorView: UIView!
    
    var colorA = UIColor(red: 0.9, green: 0.5, blue: 0.3, alpha: 1.0)
    var colorB = UIColor(red: 0.9, green: 0.5, blue: 0.3, alpha: 1.0)
    
    @IBAction func startStopScrollingClicked(sender: AnyObject) {
        self.stillPainter.touchPaintEnabled = !self.stillPainter.touchPaintEnabled
        
        setZoomMenuTexts()
    }
    
    @IBAction func zoomOutButtonClicked(sender: AnyObject) {
        self.stillPainter.zoomOut()
    }
    
    var isColorA = true
    @IBAction func changeColorClicked(sender: AnyObject) {
        if (isColorA) {
            changeColor(colorB)
        } else {
            changeColor(colorA)
        }
        isColorA = !isColorA
    }
    
    //undo button clicked
    @IBAction func undoClicked(sender: AnyObject) {
        if (self.videoPainter.isRunning) {
            return
        }
            
        self.stillPainter.stepBackward()
        self.undoButton.enabled = self.stillPainter.canStepBackward
    }
    
    deinit {
        // perform the deinitialization
        NSLog("deinit AugmentedViewController")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //iniitialize a new instance of video painter
        videoPainter = CBVideoPainter(cameraAtPosition: AVCaptureDevicePosition.Back, delegate: self)
        videoPainter.paintColor = colorA
        
        self.zoomMenu.hidden = true
        setZoomMenuTexts()
        
        colorA = stillPainter.paintColor
        stillPainter.contentMode = UIViewContentMode.ScaleAspectFit
        currentColorView.backgroundColor = stillPainter.paintColor
        
        stillPainter.zoomingCompletedBlock = ({[weak self] in
            if let strongSelf = self {
                strongSelf.zoomMenu.hidden = (strongSelf.stillPainter.zoomScale == 1.0)
                strongSelf.setZoomMenuTexts()
            }
        })
        
        //when the undo history has changed, check to see if we can undo
        stillPainter.historyChangedBlock = ({[weak self] in
            if let strongSelf = self {
                strongSelf.undoButton.enabled = strongSelf.stillPainter.canStepBackward
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        augmentedView.frame = self.view.frame
        //set its output to the view where we want it displayed
        videoPainter.output = augmentedView
        
        //start running the augmented reality
        startStopAugmentedReality(true)
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        startStopAugmentedReality(false)
    }
    
    //when clicked, clear all points currently selected
    @IBAction func clearPointsClicked(sender: AnyObject) {
        videoPainter.clearAll()
        stillPainter.clearAll()
    }
    
    @IBAction func startStopClicked(sender: AnyObject) {
        
        startStopAugmentedReality(!videoPainter.isRunning)
    }
    
    func startStopAugmentedReality(start:Bool) {
        if (start) {
            self.stillPainter.hidden = true
            captureButton.title = "Capture"
            videoPainter.output!.hidden = false
            videoPainter.startRunning()
        }
        else {
            self.stillPainter.hidden = true
            captureButton.title = "Retake"
            videoPainter.stopRunning()
            videoPainter.output!.hidden = true
        }
    }
    
    //when clicked, clear all points currently selected
    @IBAction func captureClicked(sender: AnyObject) {
        
        if (!self.videoPainter.isRunning) {
            startStopAugmentedReality(true)
        }
        else if (gotoStillView) {

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
            let imagePaintViewController = segue.destinationViewController as! StillViewController
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
    
    //change the CBImagePainter image and also the current displayed color swatch
    func changeColor(color:UIColor) {
        videoPainter.paintColor = color
        stillPainter.setPaintColor(color, updateImage: true)
        currentColorView.backgroundColor = color
    }
}

