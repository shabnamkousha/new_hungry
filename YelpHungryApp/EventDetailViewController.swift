//
//  EventDetailViewController.swift
//  YelpHungryApp
//
//  Created by admin on 2/17/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import YelpAPI

class EventDetailViewController: UIViewController {
    
    @IBOutlet var prevImg : UIImageView!
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var ratingImg : UIImageView!
    @IBOutlet var reviewLabel : UILabel!
    @IBOutlet var priceLabel : UILabel!
    @IBOutlet var categoryLabel : UILabel!
    @IBOutlet var hoursLabel : UILabel!
    @IBOutlet var directionsLabel : UILabel!
    @IBOutlet var phonenumberLabel : UILabel!
    @IBOutlet var getdirectionLabel :UILabel!
    @IBOutlet var filterButton : UIButton!
    @IBOutlet var loveButton : UIButton!
    @IBOutlet var dislikeButton : UIButton!
    @IBOutlet var likeButton : UIButton!

    @IBOutlet var line1 : UIView!
    @IBOutlet var line2 : UIView!
    @IBOutlet var line3 : UIView!
    @IBOutlet var line4 : UIView!
    @IBOutlet var navView : UIView!
    @IBOutlet var navTitle : UILabel!
    
    var client : YLPClient!
    var spinner : UIActivityIndicatorView!
    var flag = false
    var timer : Timer!
    var original = 0
    //////////
    var businessid : String!
    var coordinate : YLPCoordinate!
    
    var openhour = ""
    var name = ""
    var photo = ""
    var review  = 0
    var rating  = 0.0
    var price = ""
    var category = [String] ()
    var direction = ""
    var phonenumber = ""
    var location : Dictionary<String, String> = [:]
    var address = ""
    var curRow = 0
    var likeState = true
    let delegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate.setNavAndStatusBarColor(navView : navView, navTitle : navTitle)
        // Do any additional setup after loading the view.
                client = delegate.viewController?.client
        delegate.eventdetailController = self
        
        spinner = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        let frame = self.view.frame
        spinner.center = CGPoint.init(x: frame.size.width / 2, y: frame.size.height / 2)
        self.view.addSubview(spinner)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        spinner.startAnimating()
        self.setClickDisable()
        
        flag = false
        if timer == nil {
            timer = Timer()
        }
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(EventDetailViewController.checkIfFinished), userInfo: nil, repeats: true)
        
        let today = Calendar.current
        let date = Date()
        var datetype : Set<Calendar.Component> = Set()
        datetype.insert(Calendar.Component.weekday)
        let components = today.dateComponents(datetype, from: date)
        var weekday = components.weekday
        weekday = (weekday! + 5) % 7
        
        client.business(withId: self.businessid) { (business : Dictionary?, error : Error?) in
            if error == nil {
                self.flag = false
                if business?["hours"] == nil {
                    self.openhour = "No information about open hour..."
                }else{
                    let hours = business?["hours"] as! Array<NSObject>
                    let open_hours = hours[0] as! Dictionary<String, Any>
                    let open_hours_ary = open_hours["open"] as! Array<NSObject>
                    let today_hours = open_hours_ary[weekday!] as! Dictionary<String, NSObject>
                    let is_overnight = today_hours["is_overnight"] as! Bool
                    let start = today_hours["start"] as! String
                    let end = today_hours["end"] as! String
                    
                    if is_overnight{
                        let index2 = start.index(start.startIndex, offsetBy: 2)
                        let index3 = start.index(start.endIndex, offsetBy: -2)
                        let index4 = end.index(end.startIndex, offsetBy: 2)
                        let index5 = end.index(end.endIndex, offsetBy: -2)
                        
                        var sthour = Int.init(start.substring(to: index2))!
                        var enhour = Int.init(end.substring(to: index4))!
                        let stmin = Int.init(start.substring(from: index3))!
                        let enmin = Int.init(start.substring(from: index5))!
                        
                        var amstate_start = true
                        var amstate_end = true
                        if sthour > 12 {
                            sthour -= 12
                            amstate_start = false
                        }
                        if enhour > 12 {
                            enhour -= 12
                            amstate_end = false
                        }
                        
                        self.openhour = "Hours Today: \(sthour):\(stmin) "
                        if amstate_start {
                            self.openhour += "AM"
                        }else{
                            self.openhour += "PM"
                        }
                        self.openhour += " - " + "\(enhour):\(enmin) "
                        if amstate_end {
                            self.openhour += "AM"
                        }else{
                            self.openhour += "PM"
                        }
                        
                    }else{
                        let index2 = start.index(start.startIndex, offsetBy: 2)
                        let index3 = start.index(start.endIndex, offsetBy: -2)
                        let index4 = end.index(end.startIndex, offsetBy: 2)
                        let index5 = end.index(end.endIndex, offsetBy: -2)
                        
                        var sthour = Int.init(start.substring(to: index2))!
                        var enhour = Int.init(end.substring(to: index4))!
                        let stmin = Int.init(start.substring(from: index3))!
                        let enmin = Int.init(start.substring(from: index5))!
                        
                        var amstate_start = true
                        var amstate_end = true
                        if sthour > 12 {
                            sthour -= 12
                            amstate_start = false
                        }
                        if enhour > 12 {
                            enhour -= 12
                            amstate_end = false
                        }
                        self.openhour = "Hours Today: \(sthour):\(stmin) "
                        if amstate_start {
                            self.openhour += "AM"
                        }else{
                            self.openhour += "PM"
                        }
                        self.openhour += " - " + "\(enhour):\(enmin) "
                        if amstate_end {
                            self.openhour += "AM"
                        }else{
                            self.openhour += "PM"
                        }
                    }
                }
                self.name = business?["name"] as! String
                if business?["review_count"] != nil{
                    self.review = business?["review_count"] as! Int
                }else{
                    self.review = 0
                }
                if business?["price"] != nil{
                    self.price = business?["price"] as! String
                }else{
                    self.price = ""
                }
                if business?["rating"] != nil{
                    self.rating = business?["rating"] as! Double
                }else{
                    self.rating = 0
                }
                if business?["phone"] != nil{
                    self.phonenumber = business?["phone"] as! String
                }else{
                    self.phonenumber = ""
                }
                if business?["image_url"] != nil{
                    self.photo = business?["image_url"] as! String
                }else{
                    self.photo = ""
                }
                self.category = [String] ()
                let categorylist = business?["categories"] as! Array<NSObject>
                for item in categorylist {
                    let dic = item as! Dictionary<String, String>
                    self.category.append(dic["title"]!)
                }
                
                let dic = business?["location"] as! Dictionary<String, Any>
                self.location["city"] = dic["city"] as? String
                self.location["state"] = dic["state"] as? String
                self.location["zip_code"] = dic["zip_code"] as? String
                var adrary = [String] ()
                if dic["address1"] != nil {
                    adrary.append(dic["address1"] as! String)
                }
                if dic["adress2"] != nil {
                    adrary.append(dic["address2"] as! String)
                }
                if dic["adress2"] != nil {
                    adrary.append(dic["address3"] as! String)
                }
                self.address = adrary.joined(separator: " ")
                
                self.flag = true
            }else{
                print("Error reading business with id!")
            }
        }
    }
    
    func setClickDisable() {
        line1.isHidden = true
        line2.isHidden = true
        line3.isHidden = true
        line4.isHidden = true
        filterButton.isUserInteractionEnabled = false
        loveButton.isUserInteractionEnabled = false
        likeButton.isUserInteractionEnabled = false
        dislikeButton.isUserInteractionEnabled = false
    }
    
    func setClickEnable() {
        filterButton.isUserInteractionEnabled = true
        loveButton.isUserInteractionEnabled = true
        likeButton.isUserInteractionEnabled = true
        dislikeButton.isUserInteractionEnabled = true
        
        line1.isHidden = false
        line2.isHidden = false
        line3.isHidden = false
        line4.isHidden = false
    }

    
    func checkIfFinished() {
        if flag == false {
            return
        }
        flag = false
        titleLabel.text = self.name
        priceLabel.text = self.price
        reviewLabel.text = String.init(format: "\(self.review) Reviews")
        
        let ratingimg = "rating" + String.init(self.rating)
        ratingImg.image = UIImage.init(named: ratingimg, in: Bundle.main, compatibleWith: nil)
    
        categoryLabel.text = category.joined(separator: ",")

        if self.photo != "" {
            self.prevImg.sd_setShowActivityIndicatorView(true)
            self.prevImg.sd_setIndicatorStyle(.gray)
            self.prevImg.sd_setImage(with: URL.init(string: self.photo), placeholderImage: UIImage.init(named: "defaultimg.jpg", in: Bundle.main, compatibleWith: nil))
        }else{
            self.prevImg.image = UIImage.init(named: "defaultimg.jpg", in: Bundle.main, compatibleWith: nil)
        }
        
        var addressStr = self.address
        addressStr += " " + self.location["city"]!
        addressStr += " " + self.location["state"]! + " " + self.location["zip_code"]!
        directionsLabel.text = addressStr
        
        let number = self.phonenumber
        if self.phonenumber != ""{
            let index2 = number.index(number.startIndex, offsetBy: 1)
            phonenumberLabel.text = String.init(format: "Call \(number.substring(from: index2))")
        }else{
            phonenumberLabel.text = String.init(format: "No Phone Number")
        }
        
        getdirectionLabel.text = "Get Directions"
        hoursLabel.text = self.openhour
        
        self.setClickEnable()
        spinner.stopAnimating()
        timer.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func gotoFilterSettings(_ sender: Any) {
        performSegue(withIdentifier: "fromdetailtofilter", sender: self)
    }
    
    @IBAction func gotoLikeList(_ sender: Any) {
        performSegue(withIdentifier: "fromDetailToLikeList", sender: self)
        
    }
    @IBAction func likeBtnTapped(_ sender: Any) {
        self.likeState = true
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if self.original == 0 {
            delegate.viewController?.kolodaView.swipe(.right)
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dislikeBtnTapped(_ sender: Any) {
        self.likeState = false
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if self.original == 0 {
            delegate.viewController?.kolodaView.swipe(.left)
        }else{
            delegate.viewController?.deleteLikeList(row: curRow)
            delegate.likelistViewController?.tableView.reloadData()
        }
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func phoneNumberTapped(_ sender: UITapGestureRecognizer) {
        if self.phonenumber == "" {
            //Exception
        }else{
            let phonenumber = "telprompt://" + self.phonenumber
            UIApplication.shared.open(URL.init(string: phonenumber)!, options: [:]) { (accepted : Bool) in
            }
        }
    }
    
    @IBAction func directionTapped(_ sender: UITapGestureRecognizer) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let controller = delegate.viewController! as ViewController!
        
        let destination = self.coordinate
        
        let googleMapsURLString = String.init(format: "http://maps.google.com/?saddr=%1.6f,%1.6f&daddr=%1.6f,%1.6f", (controller?.coordinate?.latitude)!, (controller?.coordinate?.longitude)!, (destination?.latitude)!, (destination?.longitude)!)
        UIApplication.shared.open(URL.init(string: googleMapsURLString)!, options: [:], completionHandler: nil)
    }
    @IBAction func goBackHungryTapped(_ sender: UITapGestureRecognizer) {
        if self.original == 0 {
            _ = self.navigationController?.popViewController(animated: true)
        }else{
            _ = self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromDetailToLikeList" {
            let likelistViewController = segue.destination as! LikeListViewController
            likelistViewController.original = 1 // from detail
        }
    }

}
