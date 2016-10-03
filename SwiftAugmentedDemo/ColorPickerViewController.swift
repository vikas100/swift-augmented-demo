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
    var asked = false;
    
    deinit {
        // perform the deinitialization
        NSLog("deinit ColorPickerViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up camera and library
        picker.delegate = self
        picker.allowsEditing = false
        
        currentColorView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        currentColorView.isHidden = true
        
        view.addSubview(currentColorView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        //load an image if none yet
        if (!asked)  {
            asked = true
            getImage()
        }
        else if (asked && colorFinder.image == nil) {
            self.navigationController!.popViewController(animated: true)
        }
        
        colorFinder.colorTouchedAtPoint = ({
            [weak self]
            (touchType: TouchStep, point:CGPoint, color:UIColor?) in
            
            if let strongSelf = self {
                if (touchType.rawValue == TouchStepEnded.rawValue) {
                    strongSelf.currentColorView.isHidden = true
                } else {
                    strongSelf.currentColorView.isHidden = false
                    strongSelf.currentColorView.backgroundColor = color
                    strongSelf.currentColorView.frame = CGRect(x: point.x + 50, y: point.y - 50,
                        width: strongSelf.currentColorView.frame.width, height: strongSelf.currentColorView.frame.height)
                }
            }
            })
    }
    
    //iPhone camera and library delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        
        loadImage(chosenImage)
        
        dismiss(animated: true, completion: nil) //5
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //get image clicked or called internally
    @IBAction func getImage() {
        let alert = UIAlertController(title: "Image Source", message: "Pick an initial image source", preferredStyle: UIAlertControllerStyle.alert);
        
        
        if (UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.rear)) {
            alert.addAction(UIAlertAction(title: "Device Camera", style: UIAlertActionStyle.default, handler: { action in
                self.picker.sourceType = .camera
                self.present(self.picker, animated: true, completion: nil)
            }));
        }
        
        alert.addAction(UIAlertAction(title: "Library", style: UIAlertActionStyle.default, handler: { action in
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true, completion: nil)
        }));
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { action in
            self.navigationController!.popViewController(animated: true)
        }));
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //load an image into painter
    func loadImage(_ image: UIImage!) {
        colorFinder.image = image
    }
}

