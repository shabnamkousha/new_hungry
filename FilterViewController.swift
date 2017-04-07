//
//  FilterViewController.swift
//  YelpHungryApp
//
//  Created by admin on 2/20/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import YelpAPI

class FilterViewController: UIViewController, MultiSelectSegmentedControlDelegate,UIPickerViewDelegate,UIPickerViewDataSource{
    
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    @IBOutlet var multiSegment : MultiSelectSegmentedControl!
    @IBOutlet var opennowSwitch : UISwitch!
    @IBOutlet var hotandnewSwitch : UISwitch!
    @IBOutlet var waitlistreservationSwitch: UISwitch!
    @IBOutlet var deals : UISwitch!
    @IBOutlet var sortPicker : UIPickerView!
    @IBOutlet var foodPicker : UIPickerView!
    @IBOutlet var specialCategorySegment : MultiSelectSegmentedControl!
    
    @IBOutlet var searchButton : UIButton!
    @IBOutlet var cancelButton : UIButton!

    var segmentStates = [false, false, false, false]
    var specialStates = [false, false, false]
    
    var sortPickerData = ["Distance", "Rating"]
    var foodPickerData = ["All", "American","Asian Fusion", "BBQ", "Brazilian", "Brunch","Buffets", "Burger", "Cafe", "Chinese", "Delis", "FastFood", "Food Court", "French","Indian","Italian","Japanese","Kebab","Korean","Mediterranean","Mexican","Pizza","Salad","Sandwiches","Seafood","Soup","Steakhouses","Sushi Bars","Thai","Vegetarian","Vietnamese"]
    
    var sortPickerState = 0, foodPickerState = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.sortPicker.dataSource = self
        self.sortPicker.delegate = self
        self.foodPicker.dataSource = self
        self.foodPicker.delegate = self
        self.multiSegment.delegate = self
        self.specialCategorySegment.delegate = self
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        let delegate  = UIApplication.shared.delegate as! AppDelegate
        delegate.filterController = self
        
        searchButton.layer.borderColor = UIColor.lightGray.cgColor
        searchButton.layer.borderWidth = 3
        cancelButton.layer.borderColor = UIColor.lightGray.cgColor
        cancelButton.layer.borderWidth = 3
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == sortPicker {
            return sortPickerData.count
        }
        return foodPickerData.count
    }
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        if pickerView == sortPicker {
//            return sortPickerData[row]
//        }
//        return foodPickerData[row]
//    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pickerLabel = view as? UILabel
        
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            pickerLabel?.textAlignment = NSTextAlignment.center
        }
        
        if pickerView == sortPicker {
            pickerLabel?.text = sortPickerData[row]
        }else{
            pickerLabel?.text = foodPickerData[row]
        }
        return pickerLabel!;
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == sortPicker {
            sortPickerState = row
        }else{
            foodPickerState = row
        }
    }
    
    @IBAction func searchClicked(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func multiSelect(_ multiSelecSegmendedControl: MultiSelectSegmentedControl!, didChangeValue value: Bool, at index: UInt) {
        if multiSelecSegmendedControl == self.multiSegment {
            let nIndex = Int.init(index)
            segmentStates[nIndex] = value
        }else{
            let nIndex = Int.init(index)
            specialStates[nIndex] = value
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let controller = delegate.viewController
        let price = controller?.filters["price"] as! Array<String>
        let priceset = NSMutableIndexSet.init()
        
        self.segmentStates = [false, false, false, false]
        for item in price {
            priceset.add(Int.init(item)! - 1)
            self.segmentStates[Int.init(item)! - 1] = true
        }
        self.multiSegment.selectedSegmentIndexes = priceset
        
        let sorttype = controller?.filters["sortby"] as! YLPSortType
        if sorttype == YLPSortType.distance {
            self.sortPickerState = 0
            self.sortPicker.selectRow(0, inComponent: 0, animated: true)
        }else{
            self.sortPickerState = 1
            self.sortPicker.selectRow(1, inComponent: 0, animated: true)
        }
        
        let foodtype = controller?.filters["categories"] as! Array<String>
        if foodtype == (controller?.all_categories)! {
            self.foodPickerState = 0
            self.foodPicker.selectRow(0, inComponent: 0, animated: true)
        }else if foodtype.count == 2 {
            self.foodPickerState = 0
            self.foodPicker.selectRow(1, inComponent: 0, animated: true)
        }else{
            for i in 2...((controller?.all_categories.count)! - 1){
                if foodtype[0] == controller?.all_categories[i] {
                    self.foodPickerState = i
                    self.foodPicker.selectRow(i, inComponent: 0, animated: true)
                }
            }
        }
        let specialset = NSMutableIndexSet.init()
        self.specialStates = [false,false, false]
        if (controller?.specialCategory.contains("gluten_free"))! {
            self.specialStates[0] = true
            specialset.add(0)
        }
        if (controller?.specialCategory.contains("kosher"))! {
            self.specialStates[1] = true
            specialset.add(1)
        }
        if (controller?.specialCategory.contains("halal"))! {
            self.specialStates[2] = true
            specialset.add(2)
        }
        self.specialCategorySegment.selectedSegmentIndexes = specialset
        
        let open_now = controller?.filters["open_now"] as! String
        if open_now == "true" {
            opennowSwitch.setOn(true, animated: true)
        }else{
            opennowSwitch.setOn(false, animated: true)
        }
        let attributes = controller?.filters["attributes"] as! Array<String>
        for attrib in attributes {
            if attrib == "hot_and_new" {
                hotandnewSwitch.setOn(true, animated: true)
                continue
            }
            if attrib == "waitlist_reservation" {
                waitlistreservationSwitch.setOn(true, animated: true)
                continue
            }
            if attrib == "deals" {
                deals.setOn(true, animated: true)
                continue
            }
        }
    }

}
