//
//  ContentViewController.swift
//  YelpHungryApp
//
//  Created by admin on 2/11/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {
    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var levelLabel : UILabel!
    @IBOutlet var distanceLabel : UILabel!
    @IBOutlet var previewImg : UIImageView!
    @IBOutlet var ratingImg : UIImageView!
    @IBOutlet var categoryLabel : UILabel!
    
    var pageIndex : Int!
    
    init(page : Int) {
        super.init(nibName: "ContentView", bundle: nil)
        self.pageIndex = page
    }
    
    init() {
        super.init(nibName: "ContentView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
