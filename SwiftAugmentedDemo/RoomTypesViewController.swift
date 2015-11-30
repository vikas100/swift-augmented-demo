//
//  RoomTypesViewController.swift
//  SwiftAugmentedDemo
//
//  Created by Joel Teply on 10/27/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import UIKit

class RoomTypesViewController: UITableViewController, ChooseImageDelegate {
    
    weak internal var delegate: ChooseImageDelegate?
    var roomTypes : NSArray = []
    var selectedRoomType : String!

    override func viewDidLoad() {
        super.viewDidLoad()

        let roomsPath = NSBundle.mainBundle().pathForResource("Rooms", ofType: nil)
        
        do {
            try roomTypes = NSFileManager.defaultManager().contentsOfDirectoryAtPath(roomsPath!)
        }
        catch let error as NSError {
            error.description
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomTypes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel!.text = roomTypes[indexPath.row] as? String
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedRoomType = roomTypes[indexPath.row] as? String
        
        performSegueWithIdentifier("chooseImage", sender: self)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let roomSelector = segue.destinationViewController as? ChooseImageViewController {
            roomSelector.delegate = self
            roomSelector.roomDirectoryName = self.selectedRoomType
        }
    }

    func imageChosen(image : UIImage) {
        self.delegate?.imageChosen(image)
        //unwindForSegue(<#T##unwindSegue: UIStoryboardSegue##UIStoryboardSegue#>, towardsViewController: <#T##UIViewController#>)
    }
}
