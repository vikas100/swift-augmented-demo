//
//  ViewController.swift
//  SwiftAugmentedDemo
//
//  Created by Joel Teply on 3/27/15.
//  Copyright (c) 2015 Joel Teply. All rights reserved.
//

import UIKit

class StillViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChooseImageDelegate {
    
    @IBOutlet var stillPainter: CBImagePainter!
    
    @IBOutlet weak var decommitButton: UIBarButtonItem!
    @IBOutlet weak var commitButton: UIBarButtonItem!
    @IBOutlet weak var colorButton: UIBarButtonItem!
    @IBOutlet weak var currentColorView: UIView!
    @IBOutlet weak var undoButton: UIBarButtonItem!
    
    @IBOutlet weak var zoomMenu: UIToolbar!
    @IBOutlet weak var zoomStartStopPaintingButton: UIBarButtonItem!
    @IBOutlet weak var zoomOutButton: UIBarButtonItem!
    
    var hasImage = false
    var savePath: String!
    var projectID: String!
    let colorA = UIColor(red: 0.9, green: 0.5, blue: 0.3, alpha: 1.0) //Orange
    let colorB = UIColor(red: 0.6941176471, green: 0.6431372549, blue: 0.568627451, alpha: 1.0)
    
    var imageToLoad: CBImagePainterImage?
    
    let picker = UIImagePickerController()
    
    deinit {
        // perform the deinitialization
        NSLog("deinit StillViewController")
    }

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
        stillPainter.historyChangedBlock = ({[weak self] in
            if let strongSelf = self {
                strongSelf.undoButton.enabled = strongSelf.stillPainter.canStepBackward
            }
        })
        
        stillPainter.contentMode = UIViewContentMode.ScaleAspectFit
        currentColorView.backgroundColor = stillPainter.paintColor
        
        //started a click of a tool
        stillPainter.startedToolBlock = ({[weak self] (toolMode: ToolMode) in
            if let strongSelf = self {
                if (toolMode.rawValue == ToolModeRectangle.rawValue) {
                    strongSelf.decommitButton.enabled = true
                    strongSelf.commitButton.enabled = true
                } else {
                    strongSelf.decommitButton.enabled = false
                    strongSelf.commitButton.enabled = false
                }
            }
        })
        
        self.zoomMenu.hidden = true
        setZoomMenuTexts()
        
        stillPainter.zoomingCompletedBlock = ({[weak self] in
            if let strongSelf = self {
                strongSelf.zoomMenu.hidden = (strongSelf.stillPainter.zoomScale == 1.0)
                strongSelf.setZoomMenuTexts()
            }
        })
        
        //set the current color view in our interface to the paint color that stillPainter defaults to
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        //load an image if none yet
        if (nil != imageToLoad) {
            self.stillPainter.setStillImage(imageToLoad)
            hasImage = true;
            imageToLoad = nil;
        }
        
        if (!hasImage)  {
            getImage()
        }
        
        self.undoButton.enabled = self.stillPainter.canStepBackward
    }
    
    //UI button click events
    @IBAction func decommitClicked(sender: AnyObject) {
        self.stillPainter.decommitChanges();
    }
    
    @IBAction func commitClicked(sender: AnyObject) {
        self.stillPainter.commitChanges();
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
    
    @IBAction func startStopScrollingClicked(sender: AnyObject) {
        self.stillPainter.touchPaintEnabled = !self.stillPainter.touchPaintEnabled
        
        setZoomMenuTexts()
    }
    
    @IBAction func zoomOutButtonClicked(sender: AnyObject) {
        self.stillPainter.zoomOut()
    }

    //iPhone camera and library delegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        loadImage(chosenImage, hasMasking: false)
        dismissViewControllerAnimated(true, completion: nil) //5
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
        getImage()
    }
    
    //get image clicked or called internally
    @IBAction func getImage() {
        let alert = UIAlertController(title: "Image Source", message: "Pick an initial image source", preferredStyle: UIAlertControllerStyle.Alert);
        
        
        if (UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Rear)) {
            alert.addAction(UIAlertAction(title: "Device Camera", style: UIAlertActionStyle.Default, handler: { action in
                self.picker.sourceType = .Camera
                self.presentViewController(self.picker, animated: true, completion: nil)
            }));
        }
        
        alert.addAction(UIAlertAction(title: "Sample Room (pre-masked)", style: UIAlertActionStyle.Default, handler: { action in
            self.performSegueWithIdentifier("showRoomTypes", sender: self)
        }));
        
        alert.addAction(UIAlertAction(title: "Basic Unmasked Image", style: UIAlertActionStyle.Default, handler: { action in
            self.loadImage(UIImage(named:"shutterstock_13368892.jpg"), hasMasking: false)
        }));
        
        alert.addAction(UIAlertAction(title: "Library", style: UIAlertActionStyle.Default, handler: { action in
            self.picker.sourceType = .PhotoLibrary
            self.presentViewController(self.picker, animated: true, completion: nil)
        }));
        
        if ((projectID) != nil) {
            alert.addAction(UIAlertAction(title: "Saved Project", style: UIAlertActionStyle.Default, handler: { action in
                self.loadClicked(self.projectID)
            }));
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //load an image into painter
    func loadImage(image: UIImage!, hasMasking: Bool) {
        self.stillPainter.loadImage(image, hasAlphaMasking: hasMasking)
        hasImage = true
        changeColor(colorA)
        undoButton.enabled = self.stillPainter.canStepBackward
    }
    
    //Upon click, create a menu to choose the current tool
    @IBAction func changeTool() {
        let alert = UIAlertController(title: "Change Tool", message: "Change Visualizer Tool", preferredStyle: UIAlertControllerStyle.Alert);
        
        
        alert.addAction(UIAlertAction(title: "Erase at Point", style: UIAlertActionStyle.Default, handler: { action in
            self.stillPainter.toolMode = ToolModeEraser
        }));
        alert.addAction(UIAlertAction(title: "Rectangle", style: UIAlertActionStyle.Default, handler: { action in
            self.stillPainter.toolMode = ToolModeRectangle
        }));
        alert.addAction(UIAlertAction(title: "Fill Only", style: UIAlertActionStyle.Default, handler: { action in
            self.stillPainter.toolMode = ToolModeFill
        }));
        alert.addAction(UIAlertAction(title: "Paintbrush (Default)", style: UIAlertActionStyle.Default, handler: { action in
            self.stillPainter.toolMode = ToolModePaintbrush
        }));
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //undo button clicked
    @IBAction func undoClicked(sender: AnyObject) {
        self.stillPainter.stepBackward()
        self.undoButton.enabled = self.stillPainter.canStepBackward
    }
    
    //share clicked
    @IBAction func shareClicked(sender: AnyObject) {
        if let imageToSave = self.stillPainter.getRenderedImage()
        {
            UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
            
            let alert = UIAlertController(title: "Image Saved", message: "Image was saved to camera roll", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //change the CBImagePainter image and also the current displayed color swatch
    func changeColor(color:UIColor) {
        stillPainter.setPaintColor(color, updateImage: true)
        currentColorView.backgroundColor = color
    }
    
    //save project clicked
    @IBAction func saveClicked(sender: AnyObject) {
        
        projectID = stillPainter.saveProjectToDirectory(savePath, saveState: true)
        
        print("Project saved to \(savePath)/\(projectID)")
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(projectID, forKey: "projectID")
        userDefaults.synchronize()
        
        let alert = UIAlertController(title: "Project Saved", message: "Project was saved with projectID: " + projectID, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:nil));
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //load project clicked
    @IBAction func loadClicked(sender: AnyObject) {
        stillPainter.loadProject("c7a2a1f6-af34-4f9b-8a6e-2c1c197b84cd", fromDirectory: savePath)
    }
    
    func setZoomMenuTexts() {
        if (self.stillPainter.touchPaintEnabled) {
            self.zoomStartStopPaintingButton.title = "Enable Scrolling"
        }
        else {
            self.zoomStartStopPaintingButton.title = "Switch to Painting"
        }
    }
    
    @IBAction func returnFromImageChoice(segue: UIStoryboardSegue) {
        
        print("Called goToSideMenu: unwind action")
        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let roomSelector = segue.destinationViewController as? RoomTypesViewController {
            roomSelector.delegate = self
        }
    }
    
    func imageChosen(image : UIImage) {
        self.loadImage(image, hasMasking: true)
    }
}

