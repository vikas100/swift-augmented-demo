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

        let roomsPath = Bundle.main.path(forResource: "Rooms", ofType: nil)
        
        do {
            try roomTypes = FileManager.default.contentsOfDirectory(atPath: roomsPath!) as NSArray
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomTypes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel!.text = roomTypes[(indexPath as NSIndexPath).row] as? String
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRoomType = roomTypes[(indexPath as NSIndexPath).row] as? String
        
        performSegue(withIdentifier: "chooseImage", sender: self)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let roomSelector = segue.destination as? ChooseImageViewController {
            roomSelector.delegate = self
            roomSelector.roomDirectoryName = self.selectedRoomType
        }
    }

    func imageChosen(_ image : UIImage) {
        self.delegate?.imageChosen(image)
        //unwindForSegue(<#T##unwindSegue: UIStoryboardSegue##UIStoryboardSegue#>, towardsViewController: <#T##UIViewController#>)
    }
}
