//
//  ViewController.swift
//  SwiftAugmentedDemo
//
//  Created by Joel Teply on 3/27/15.
//  Copyright (c) 2015 Joel Teply. All rights reserved.
//

import UIKit

class StillViewController: UIViewController {
    
    @IBOutlet var imagePainter: CBImagePainter!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //imagePainter.loadImage(UIImage(named:"living-room-1-masked"), hasAlphaMasking: true);
        
        imagePainter.loadImage(UIImage(named:"shutterstock_13368892.jpg"), hasAlphaMasking: false);
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

