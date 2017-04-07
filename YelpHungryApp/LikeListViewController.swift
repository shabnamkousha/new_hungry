//
//  LikeListViewController.swift
//  YelpHungryApp
//
//  Created by admin on 2/17/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import YelpAPI

class LikeListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var filterButton : UIButton!
    @IBOutlet var tableView : UITableView!
    @IBOutlet var clearallButton : UIButton!
    @IBOutlet var navView : UIView!
    @IBOutlet var navTitle : UILabel!
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var controller : ViewController!
    var currentItem : Restaurants!
    var selrow = 0
    var original = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate.setNavAndStatusBarColor(navView: navView, navTitle: navTitle)
        controller = delegate.viewController
        // Do any additional setup after loading the view.
        delegate.likelistViewController = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clearallButtonTapped(_ sender: Any) {
        controller.deleteAllLikeList()
        tableView.reloadData()
    }
    
    @IBAction func goBackHungryTapped(_ sender: UITapGestureRecognizer) {
        if original == 0 {
            _ = self.navigationController?.popViewController(animated: true)
        }else{
            _ = self.navigationController?.popToRootViewController(animated: true)
            //performSegue(withIdentifier: "fromLikeListToHungry", sender: self)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "fromlisttodetail" {
            let destination = segue.destination as! EventDetailViewController
            destination.businessid = currentItem.businessid
            destination.coordinate = YLPCoordinate(latitude: currentItem.latitude, longitude: currentItem.longitude)
            destination.original = 1 //like list view controller
            destination.curRow = selrow
        }
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return controller.likeList.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "likelistcell", for: indexPath) as! LikeListTableViewCell
        // Configure the cell...
        cell.nameLabel.text = controller.likeList[indexPath.row].name
        cell.categoryLabel.text = controller.likeList[indexPath.row].category
        return cell
    }

    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
//            tableView.deleteRows(at: [indexPath], with: .fade)
            controller.deleteLikeList( row: indexPath.row)
            
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentItem = controller.likeList[indexPath.row]
        selrow = indexPath.row
        performSegue(withIdentifier: "fromlisttodetail", sender: self)
    }
}
