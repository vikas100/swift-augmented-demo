//
//  ViewController.swift
//  SwiftAugmentedDemo
//
//  Created by Joel Teply on 3/27/15.
//  Copyright (c) 2015 Joel Teply. All rights reserved.
//

import UIKit
import AVFoundation
import GLKit

class AugmentedViewController: UIViewController {
    
    var videoPainter: CBVideoPainter!
    var savedPainterImage: CBImagePainterImage!
    let kVideoToImageSegueIdentifier = "StillViewSegue"
    var gotoStillView = true
    
    @IBOutlet weak var augmentedView: GLKView!
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
    
    @IBAction func startStopScrollingClicked(_ sender: AnyObject) {
        self.stillPainter.touchPaintEnabled = !self.stillPainter.touchPaintEnabled
        
        setZoomMenuTexts()
    }
    
    @IBAction func zoomOutButtonClicked(_ sender: AnyObject) {
        self.stillPainter.zoomOut()
    }
    
    var isColorA = true
    @IBAction func changeColorClicked(_ sender: AnyObject) {
        if (isColorA) {
            changeColor(colorB)
        } else {
            changeColor(colorA)
        }
        isColorA = !isColorA
    }
    
    //undo button clicked
    @IBAction func undoClicked(_ sender: AnyObject) {
        if (self.videoPainter.isRunning) {
            return
        }
            
        self.stillPainter.stepBackward()
        self.undoButton.isEnabled = self.stillPainter.canStepBackward
    }
    
    deinit {
        // perform the deinitialization
        NSLog("deinit AugmentedViewController")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //iniitialize a new instance of video painter
        videoPainter = CBVideoPainter()
        videoPainter.paintColor = colorA
        
        self.zoomMenu.isHidden = true
        setZoomMenuTexts()
        
        colorA = stillPainter.paintColor
        stillPainter.contentMode = UIViewContentMode.scaleAspectFit
        currentColorView.backgroundColor = stillPainter.paintColor
        
        stillPainter.zoomingCompletedBlock = ({[weak self] in
            if let strongSelf = self {
                strongSelf.zoomMenu.isHidden = (strongSelf.stillPainter.zoomScale == 1.0)
                strongSelf.setZoomMenuTexts()
            }
        })
        
        //when the undo history has changed, check to see if we can undo
        stillPainter.historyChangedBlock = ({[weak self] in
            if let strongSelf = self {
                strongSelf.undoButton.isEnabled = strongSelf.stillPainter.canStepBackward
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        augmentedView.frame = self.view.frame
        //set its output to the view where we want it displayed
        videoPainter.output = augmentedView
        
        //start running the augmented reality
        startStopAugmentedReality(true)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        startStopAugmentedReality(false)
    }
    
    //when clicked, clear all points currently selected
    @IBAction func clearPointsClicked(_ sender: AnyObject) {
        videoPainter.clearAll()
        stillPainter.clearAll()
    }
    
    @IBAction func startStopClicked(_ sender: AnyObject) {
        
        startStopAugmentedReality(!videoPainter.isRunning)
    }
    
    func startStopAugmentedReality(_ start:Bool) {
        if (start) {
            self.stillPainter.isHidden = true
            captureButton.title = "Capture"
            videoPainter.output!.isHidden = false
            videoPainter.startRunning()
        }
        else {
            self.stillPainter.isHidden = true
            captureButton.title = "Retake"
            videoPainter.stopRunning()
            videoPainter.output!.isHidden = true
        }
    }
    
    //when clicked, clear all points currently selected
    @IBAction func captureClicked(_ sender: AnyObject) {
        
        if (!self.videoPainter.isRunning) {
            startStopAugmentedReality(true)
        }
        else if (gotoStillView) {

            self.videoPainter.captureCurrentState({(imageWithMask: CBImagePainterImage?) -> Void in
                self.savedPainterImage = imageWithMask
                self.startStopAugmentedReality(false)
                self.performSegue(withIdentifier: self.kVideoToImageSegueIdentifier, sender: self)
            })
        } else {
            self.videoPainter.captureCurrentState(self.stillPainter, completed: { () -> Void in
                self.startStopAugmentedReality(false)
                self.stillPainter.isHidden = false
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kVideoToImageSegueIdentifier {
            let imagePaintViewController = segue.destination as! StillViewController
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
    func changeColor(_ color:UIColor) {
        videoPainter.paintColor = color
        stillPainter.setPaint(color, updateImage: true)
        currentColorView.backgroundColor = color
    }
}

