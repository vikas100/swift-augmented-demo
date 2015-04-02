//
//  ViewController.swift
//  SwiftAugmentedDemo
//
//  Created by Joel Teply on 3/27/15.
//  Copyright (c) 2015 Joel Teply. All rights reserved.
//

import UIKit

class StillViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var imagePainter: CBImagePainter!
    
    @IBOutlet weak var decommitButton: UIBarButtonItem!
    @IBOutlet weak var commitButton: UIBarButtonItem!
    @IBOutlet weak var colorButton: UIBarButtonItem!
    @IBOutlet weak var currentColorView: UIView!
    @IBOutlet weak var undoButton: UIBarButtonItem!
    
    var hasImage = false
    var savePath: String!
    var projectID: String!
    
    let picker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up camera and library
        picker.delegate = self
        picker.allowsEditing = false
        
        //internal paths
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        savePath = documentsPath.stringByAppendingPathComponent("projects")
        
        //get project ID, if we have saved once before, otherwise null
        let userDefaults = NSUserDefaults.standardUserDefaults()
        projectID = userDefaults.stringForKey("projectID")
        
        //when the undo history has changed, check to see if we can undo
        imagePainter.historyChangedBlock = ({
            self.undoButton.enabled = self.imagePainter.canStepBackward
        })
        
        //started a click of a tool
        imagePainter.startedToolBlock = ({(toolMode: ToolMode) in
            if (toolMode.value == ToolModeRectangle.value) {
                self.decommitButton.enabled = true
                self.commitButton.enabled = true
            } else {
                self.decommitButton.enabled = false
                self.commitButton.enabled = false
            }
        })
        
        //set the current color view in our interface to the paint color that imagePainter defaults to
        currentColorView.backgroundColor = imagePainter.paintColor
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        //load an image if none yet
        if (!hasImage)  {
            getImage()
        }
    }
    
    //UI button click events
    @IBAction func decommitClicked(sender: AnyObject) {
        self.imagePainter.decommitChanges();
    }
    
    @IBAction func commitClicked(sender: AnyObject) {
        self.imagePainter.commitChanges();
    }
    
    @IBAction func changeColorClicked(sender: AnyObject) {
        changeColor( UIColor(red: 0.9, green: 0.5, blue: 0.3, alpha: 1.0))
    }

    //iPhone camera and library delegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var chosenImage = info[UIImagePickerControllerOriginalImage] as UIImage //2
        loadImage(chosenImage, hasMasking: false)
        dismissViewControllerAnimated(true, completion: nil) //5
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
        getImage()
    }
    
    //get image clicked or called internally
    @IBAction func getImage() {
        var alert = UIAlertController(title: "Image Source", message: "Pick an initial image source", preferredStyle: UIAlertControllerStyle.Alert);
        
        
        if ((projectID) != nil) {
            alert.addAction(UIAlertAction(title: "Saved Project", style: UIAlertActionStyle.Default, handler: { action in
                self.loadClicked(self.projectID)
            }));
        }
        
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
        
        alert.addAction(UIAlertAction(title: "Pre-masked Image", style: UIAlertActionStyle.Default, handler: { action in
            self.loadImage(UIImage(named:"living-room-1-masked.png"), hasMasking: true)
        }));
        
        alert.addAction(UIAlertAction(title: "Basic Unmasked Image", style: UIAlertActionStyle.Default, handler: { action in
            self.loadImage(UIImage(named:"shutterstock_13368892.jpg"), hasMasking: false)
        }));
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //load an image into painter
    func loadImage(image: UIImage!, hasMasking: Bool) {
        self.imagePainter.loadImage(image, hasAlphaMasking: hasMasking)
        hasImage = true
        undoButton.enabled = false
    }
    
    //Upon click, create a menu to choose the current tool
    @IBAction func changeTool() {
        var alert = UIAlertController(title: "Change Tool", message: "Change Visualizer Tool", preferredStyle: UIAlertControllerStyle.Alert);
        
        
        alert.addAction(UIAlertAction(title: "Erase at Point", style: UIAlertActionStyle.Default, handler: { action in
            self.imagePainter.toolMode = ToolModeEraser
        }));
        alert.addAction(UIAlertAction(title: "Rectangle", style: UIAlertActionStyle.Default, handler: { action in
            self.imagePainter.toolMode = ToolModeRectangle
        }));
        alert.addAction(UIAlertAction(title: "Fill Only", style: UIAlertActionStyle.Default, handler: { action in
            self.imagePainter.toolMode = ToolModeFill
        }));
        alert.addAction(UIAlertAction(title: "Paintbrush (Default)", style: UIAlertActionStyle.Default, handler: { action in
            self.imagePainter.toolMode = ToolModePaintbrush
        }));
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //undo button clicked
    @IBAction func undoClicked(sender: AnyObject) {
        self.imagePainter.stepBackward()
        self.undoButton.enabled = self.imagePainter.canStepBackward
    }
    
    //share clicked
    @IBAction func shareClicked(sender: AnyObject) {
        let imageToSave = self.imagePainter.previewImage
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
        
        var alert = UIAlertController(title: "Image Saved", message: "Image was saved to camera roll", preferredStyle: UIAlertControllerStyle.Alert)
    
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil));
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //change the CBImagePainter image and also the current displayed color swatch
    func changeColor(color:UIColor) {
        imagePainter.setPaintColor(color, updateImage: true)
        currentColorView.backgroundColor = color
    }
    
    //save project clicked
    @IBAction func saveClicked(sender: AnyObject) {
        projectID = imagePainter.saveProjectToDirectory(savePath, saveState: true)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(projectID, forKey: "projectID")
        userDefaults.synchronize()
        
        var alert = UIAlertController(title: "Project Saved", message: "Project was saved with projectID: " + projectID, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:nil));
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //load project clicked
    @IBAction func loadClicked(sender: AnyObject) {
        imagePainter.loadProject(projectID, fromDirectory: savePath)
    }
}

