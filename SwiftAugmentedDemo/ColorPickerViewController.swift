//
//  ColorPickerViewController.swift
//  SwiftAugmentedDemo
//
//  Created by Joel Teply on 4/24/15.
//  Copyright (c) 2015 Joel Teply. All rights reserved.
//

import UIKit
import AVFoundation

class ColorPickerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var colorFinder: CBColorFinder!
    
    let picker = UIImagePickerController()
    
    let currentColorView = UIView()
    
    deinit {
        // perform the deinitialization
        println("deinit ColorPickerViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set up camera and library
        picker.delegate = self
        picker.allowsEditing = false
        
        currentColorView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        currentColorView.hidden = true
        
        view.addSubview(currentColorView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        //load an image if none yet
        if (colorFinder.image == nil)  {
            getImage()
        }
        
        colorFinder.colorTouchedAtPoint = ({
            [weak self]
            (touchType: TouchStep, point:CGPoint, color:UIColor!) in
            
            if let strongSelf = self {
                if (touchType.value == TouchStepEnded.value) {
                    strongSelf.currentColorView.hidden = true
                } else {
                    strongSelf.currentColorView.hidden = false
                    strongSelf.currentColorView.backgroundColor = color
                    strongSelf.currentColorView.frame = CGRect(x: point.x, y: point.y,
                        width: strongSelf.currentColorView.frame.width, height: strongSelf.currentColorView.frame.height)
                }
            }
        })
    }
    
    //iPhone camera and library delegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        
        loadImage(chosenImage)
        
        dismissViewControllerAnimated(true, completion: nil) //5
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
        getImage()
    }
    
    //get image clicked or called internally
    @IBAction func getImage() {
        var alert = UIAlertController(title: "Image Source", message: "Pick an initial image source", preferredStyle: UIAlertControllerStyle.Alert);
        
                
        if (UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Rear)) {
            alert.addAction(UIAlertAction(title: "Device Camera", style: UIAlertActionStyle.Default, handler: { action in
                self.picker.sourceType = .Camera
                self.presentViewController(self.picker, animated: true, completion: nil)
            }));
        }
        
        alert.addAction(UIAlertAction(title: "Library", style: UIAlertActionStyle.Default, handler: { action in
            self.picker.sourceType = .PhotoLibrary
            self.presentViewController(self.picker, animated: true, completion: nil)
        }));
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    //load an image into painter
    func loadImage(image: UIImage!) {
        colorFinder.image = image
    }
}

