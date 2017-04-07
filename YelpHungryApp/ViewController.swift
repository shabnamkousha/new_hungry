//
//  ViewController.swift
//  YelpHungryApp
//
//  Created by admin on 2/10/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import YelpAPI
import Koloda
import SDWebImage

class ViewController: UIViewController , CLLocationManagerDelegate{
    
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet var filterButton : UIButton!
    @IBOutlet var loveButton : UIButton!
    @IBOutlet var dislikeButton : UIButton!
    @IBOutlet var likeButton : UIButton!
    @IBOutlet var noLabel : UILabel!
    @IBOutlet var navView : UIView!
    @IBOutlet var navTitle : UILabel!
    
    var locationManager: CLLocationManager!
    
    var client : YLPClient? = nil, coordinate : YLPCoordinate? = nil
    var search : YLPSearch!
    
    var data_list = [YLPBusiness]()

    let appId = "bn0a5vsqZ8A8ixiJFrdLPg", secret = "7vBmuAO7mEucYKvylHwrIZE0uvVf2v94vNGALqpLPcTFkldNUOtKi9QbYtjP2zoK"
    var offset = 0

    let all_categories = [
        "newamerican",
        "tradamerican",
        "asianfusion",
        "bbq",
        "brazilian",
        "breakfast_brunch",
        "buffets",
        "burgers",
        "cafes",
        "chinese",
        "delis",
        "hotdogs",
        "food_court",
        "french",
        "indpak",
        "italian",
        "japanese",
        "kebab",
        "korean",
        "mediterranean",
        "mexican",
        "pizza",
        "salad",
        "sandwiches",
        "seafood",
        "soup",
        "steak",
        "sushi",
        "thai",
        "vegetarian",
        "vietnamese"
        ]

    var filters = [
        "sortby" : YLPSortType.distance,
        "open_now" : "true",
        "price" : [],
        "attributes" : [],
        "categories" : [
            "newamerican",
            "tradamerican",
            "asianfusion",
            "bbq",
            "brazilian",
            "breakfast_brunch",
            "buffets",
            "burgers",
            "cafes",
            "chinese",
            "delis",
            "hotdogs",
            "food_court",
            "french",
            "indpak",
            "italian",
            "japanese",
            "kebab",
            "korean",
            "mediterranean",
            "mexican",
            "pizza",
            "salad",
            "sandwiches",
            "seafood",
            "soup",
            "steak",
            "sushi",
            "thai",
            "vegetarian",
            "vietnamese"
            ]
        ] as [String : Any]
    
    var specialCategory = [String] ()
    
    var spinner : UIActivityIndicatorView!
    var flag = false
    
    var timer = Timer()
    var locationTimer = Timer()
    var selItem : YLPBusiness!
    
    var context : NSManagedObjectContext!
    var entity : NSEntityDescription!
    var likeList : [Restaurants]!
    var locationState = false
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate.setNavAndStatusBarColor(navView: navView, navTitle: navTitle)
        // Do any additional setup after loading the view, typically from a nib.
        kolodaView.delegate = self
        kolodaView.dataSource = self
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        
        delegate.viewController = self
        
        spinner = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        let frame = self.view.frame
        spinner.center = CGPoint.init(x: frame.size.width / 2, y: frame.size.height / 2)
        self.view.addSubview(spinner)
        spinner.startAnimating()
        self.setClickDisable()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 2 * 1609.34
        
        spinner.color = UIColor.gray
        YLPClient.authorize(withAppId: appId, secret: secret) { (client : YLPClient?, error : Error?) in
            self.client = client!
            self.startupdatelocation()
        }
        
        context = getContext()
        entity =  NSEntityDescription.entity(forEntityName: "Restaurants", in: context)
        
        getLikeList()
        if likeList == nil {
            likeList = [Restaurants] ()
        }
    }
    
    func startupdatelocation() {
        locationManager.startUpdatingLocation()
    }
    
    func setClickDisable() {
        filterButton.isUserInteractionEnabled = false
        loveButton.isUserInteractionEnabled = false
        likeButton.isUserInteractionEnabled = false
        dislikeButton.isUserInteractionEnabled = false
        kolodaView.isUserInteractionEnabled = false
    }
    
    func setClickEnable() {
        filterButton.isUserInteractionEnabled = true
        loveButton.isUserInteractionEnabled = true
        likeButton.isUserInteractionEnabled = true
        dislikeButton.isUserInteractionEnabled = true
        kolodaView.isUserInteractionEnabled = true
    }
    
    @IBAction func dislikeBtnClicked() {
        kolodaView?.swipe(.left)
    }
    
    @IBAction func likeBtnClicked() {
        kolodaView?.swipe(.right)
    }

    @IBAction func goToLikeList(_ sender: Any) {
        performSegue(withIdentifier: "fromHungrytoLikeList", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError: \(error)")
        
        let alertController = UIAlertController(title: "Error", message: "Failed to Get your location.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
        
    }	
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0
        {
            let location = locations.last as CLLocation!
            if locationState == false{
                print("\(location!.coordinate.latitude),\(location!.coordinate.longitude)")
                coordinate = YLPCoordinate.init(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
//                coordinate = YLPCoordinate.init(latitude: -37.830356, longitude: 144.964815)
                locationState = true
                
                spinner.startAnimating()
                searchWithClient()
                
                timer = Timer()
                timer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(ViewController.checkIfFinished), userInfo: nil, repeats: true)
                
                //manager.distanceFilter = 200
                //manager.stopUpdatingLocation()
            }
        }
    }
    
    func locationUpdate() {
        self.locationTimer.invalidate()
        
        self.locationManager.startUpdatingLocation()
    }
    
    func checkIfFinished() {
        if flag
        {
            flag = false
            //print("Loading Finished")
            
            timer.invalidate()
            ////////////////////////////////
            
            if data_list.count == 0{
                self.kolodaView.isHidden = true
                self.likeButton.isHidden = true
                self.dislikeButton.isHidden = true
                if offset == 0 {
                    self.noLabel.text = "No restaurant available with selected criteria. Please change the criteria from the filter menu!"
                }else{
                    self.noLabel.text = "No more restaurant available with selected criteria. Please change the criteria from the filter menu!"
                }
                self.noLabel.isHidden = false
                
                self.spinner.stopAnimating()
                setClickEnable()
                
                //self.data_list.removeAll()
                kolodaView.resetCurrentCardIndex()
                self.kolodaView.reloadData()
                return
            }
            self.kolodaView.isHidden = false
            self.likeButton.isHidden = false
            self.dislikeButton.isHidden = false
            self.noLabel.isHidden = true
            
            kolodaView.resetCurrentCardIndex()
            self.kolodaView.reloadData()
            self.spinner.stopAnimating()
            setClickEnable()
        }
    }
    
    func searchWithClient() {
        flag = false
        
        let sorttype = self.filters["sortby"] as! YLPSortType
        let price = filters["price"] as! Array<String>
        var categories = filters["categories"] as! Array<String>
        let attributes = filters["attributes"] as! Array<String>
        for special in specialCategory {
            categories.append(special)
        }
        
        client?.search(
            with: self.coordinate!,
            term: "restaurants",
            limit: 50,
            offset: UInt(offset),
            sort: sorttype,
            price: price,
            open_now: filters["open_now"] as! String,
            customcategories : categories,
            attributes : attributes,
            completionHandler: { (search : YLPSearch?, error: Error?) in
                self.search = search
                self.data_list = (search?.businesses)!
                self.flag = true
                self.locationState = false
        })
    }
    
    func reloadData() {
        if self.client != nil &&  coordinate != nil{
            self.setClickDisable()
            spinner.startAnimating()
            searchWithClient()
            
            timer = Timer()
            
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(ViewController.checkIfFinished), userInfo: nil, repeats: true)
        }
    }
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if #available(iOS 10.0, *) {
            return appDelegate.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
        }
        return NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    }
    
    func storeListList (business : YLPBusiness) {
        
        var searchResults = [Restaurants] ()
        let fetchRequest: NSFetchRequest<Restaurants> = Restaurants.fetchRequest()
        var item : Restaurants! = nil
        
        do {
            searchResults = try getContext().fetch(fetchRequest)
            
            for item1 in searchResults{
                let businessid = item1.businessid
                if  businessid == business.businessid {
                    item = item1
                    break
                }
            }
            
            if item == nil {
                item = Restaurants(entity: entity!, insertInto: context)
                item.businessid = business.businessid
                item.name = business.name
                item.latitude = (business.location.coordinate?.latitude)!
                item.longitude = (business.location.coordinate?.longitude)!
                
                let category = business.categories
                var str = ""
                for item in category {
                    str += item.name + ","
                }
                let index1 = str.index(str.endIndex, offsetBy: -1)
                item.category = str.substring(to: index1)
            }else{
                item.businessid = business.businessid
                item.name = business.name
                item.latitude = (business.location.coordinate?.latitude)!
                item.longitude = (business.location.coordinate?.longitude)!
                
                let category = business.categories
                var str = ""
                for item in category {
                    str += item.name + ","
                }
                let index1 = str.index(str.endIndex, offsetBy: -1)
                item.category = str.substring(to: index1)
            }
            do {
                try context.save()
                //print("saved!")
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            } catch {
                
            }
        } catch {
            print("Error with request: \(error)")
        }
        getLikeList()
    }
    
    func getLikeList () {
        //create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<Restaurants> = Restaurants.fetchRequest()
        
        do {
            likeList = try getContext().fetch(fetchRequest)
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    func deleteLikeList(row : Int) {
        context.delete(likeList[row])
        do{
            try context.save()
        } catch {
            print("Error with request: \(error)")
        }
        
        getLikeList()
    }
    
    func deleteAllLikeList() {
        for item in likeList {
            context.delete(item)
        }
        do{
            try context.save()
        }catch{
            print("Error with request: \(error)")
        }
        getLikeList()
    }
    
    func removeIfExist(business: YLPBusiness) {
        for item in likeList {
            if item.businessid == business.businessid
            {
                context.delete(item)
                do{
                    try context.save()
                } catch {
                    print("Error with request: \(error)")
                }
                getLikeList()
                break
            }
        }
    }
    
    // update the scroll view to the appropriate page
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        let controller = delegate.filterController
        let detailController = delegate.eventdetailController
        
        if detailController == unwindSegue.source {
            if (detailController?.likeState)! {
                let business = data_list[kolodaView.currentCardIndex]
                storeListList(business: business)
                
                kolodaView.swipe(SwipeResultDirection.right)
            }else{
                kolodaView.swipe(SwipeResultDirection.left)
            }
        }else{
            filters["sortby"] = (controller?.sortPickerState==0) ? YLPSortType.distance : YLPSortType.highestRated
        
            var priceary = [String]()
            for i in 0...3 {
                if (controller?.segmentStates[i])!{
                    priceary.append("\(i+1)")
                }
            }
            filters["price"] = priceary
        
            if controller?.foodPickerState == 0 {
                filters["categories"] = all_categories
            }else if controller?.foodPickerState == 1 {
                filters["categories"] = [all_categories[0], all_categories[1]]
            }else{
                filters["categories"] = [all_categories[(controller?.foodPickerState)!]]
            }
            
            self.specialCategory.removeAll()
            if (controller?.specialStates[0])! {
                specialCategory.append("gluten_free")
            }
            if (controller?.specialStates[1])! {
                specialCategory.append("kosher")
            }
            if (controller?.specialStates[2])! {
                specialCategory.append("halal")
            }
            
            var ary = [String]()
            if (controller?.hotandnewSwitch.isOn)! {
                ary.append("hot_and_new")
            }
            if (controller?.waitlistreservationSwitch.isOn)! {
                ary.append("waitlist_reservation")
            }
            if (controller?.deals.isOn)! {
                ary.append("deals")
            }
            if (controller?.opennowSwitch.isOn)!{
                filters["open_now"] = "true"
            }else{
                filters["open_now"] = "false"
            }
            filters["attributes"] = ary
            self.offset = 0
            self.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let detailController = segue.destination as! EventDetailViewController
            detailController.businessid = selItem.businessid
            detailController.coordinate = selItem.location.coordinate
            detailController.original = 0 //view controller
        }
        if segue.identifier == "fromHungrytoLikeList" {
            let likelistViewController = segue.destination as! LikeListViewController
            likelistViewController.original = 0 //from hungry
        }
    }
    
}

extension ViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        offset += data_list.count
        self.reloadData()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        selItem = data_list[index]
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        let business = data_list[index]
        if (direction == .right) || (direction == .bottomRight) || (direction == .topRight){
            storeListList(business: business)
        }else{
            removeIfExist(business: business)
        }
    }
}

// MARK: KolodaViewDataSource

extension ViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return data_list.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let controller  = ContentViewController(page: index)
        
        if (controller.view.superview == nil)
        {
            addChildViewController(controller)
            //controller.didMove(toParentViewController: self)
        }
        controller.nameLabel.text = self.data_list[index].name
        controller.levelLabel.text = self.data_list[index].price
        controller.distanceLabel.text = String.init(format: "%.1fmi", (self.data_list[index].distance / 1609.34))
        
        let ratingimg = "rating" + String.init(self.data_list[index].rating)
        controller.ratingImg.image = UIImage.init(named: ratingimg, in: Bundle.main, compatibleWith: nil)
        
        let category = self.data_list[index].categories
        var str = ""
        for item in category {
            str += item.name + ","
        }
        
        let index1 = str.index(str.endIndex, offsetBy: -1)
        controller.categoryLabel.text = str.substring(to: index1)
        
        let imgurl = self.data_list[index].imageURL
        if imgurl != nil {
            controller.previewImg.sd_setShowActivityIndicatorView(true)
            controller.previewImg.sd_setIndicatorStyle(.gray)
            controller.previewImg.sd_setImage(with: imgurl, placeholderImage: UIImage.init(named: "defaultimg.jpg", in: Bundle.main, compatibleWith: nil))
        }else{
            controller.previewImg.image = UIImage.init(named: "defaultimg.jpg", in: Bundle.main, compatibleWith: nil)
        }
        
        return controller.view
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
}

