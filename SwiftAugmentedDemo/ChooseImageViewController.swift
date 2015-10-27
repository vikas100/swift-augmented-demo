//
//  ChooseImageViewController.swift
//  SwiftAugmentedDemo
//
//  Created by Joel Teply on 10/27/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ImageCell"

internal protocol ChooseImageDelegate : NSObjectProtocol {
    func imageChosen(image : UIImage)
}

class ChooseImageViewController: UICollectionViewController {
    
    weak internal var delegate: ChooseImageDelegate?
    var roomDirectoryName : String!
    
    var imageNames : NSArray = []
    var imagesPath : String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        imagesPath = NSBundle.mainBundle().pathForResource("Rooms/" + self.roomDirectoryName, ofType: nil)
        
        do {
            try imageNames = NSFileManager.defaultManager().contentsOfDirectoryAtPath(imagesPath!)
        }
        catch let error as NSError {
            error.description
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNames.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
        let imagePath = "\(imagesPath)/\(imageNames[indexPath.row] as! String)"
        
        imageView.image = UIImage(contentsOfFile: imagePath)
        imageView.backgroundColor = UIColor.redColor()
        cell.contentView.addSubview(imageView)

        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        if let imageView = cell?.contentView.subviews[0] as? UIImageView {
            self.delegate?.imageChosen(imageView.image!)
            performSegueWithIdentifier("unwindToPainter", sender: self)
        }
    }

}
