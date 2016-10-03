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
    func imageChosen(_ image : UIImage)
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
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        imagesPath = Bundle.main.path(forResource: "Rooms/" + self.roomDirectoryName, ofType: nil)
        
        do {
            try imageNames = FileManager.default.contentsOfDirectory(atPath: imagesPath!) as NSArray
        }
        catch let error as NSError {
            error.description
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNames.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
        let imagePath = "\(imagesPath)/\(imageNames[(indexPath as NSIndexPath).row] as! String)"
        
        imageView.image = UIImage(contentsOfFile: imagePath)
        imageView.backgroundColor = UIColor.red
        cell.contentView.addSubview(imageView)

        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if let imageView = cell?.contentView.subviews[0] as? UIImageView {
            self.delegate?.imageChosen(imageView.image!)
            performSegue(withIdentifier: "unwindToPainter", sender: self)
        }
    }

}
