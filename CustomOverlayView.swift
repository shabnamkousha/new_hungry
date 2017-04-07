//
//  OverlayView.swift
//  YelpHungryApp
//
//  Created by admin on 2/14/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import Koloda

private let overlayRightImageName = "yesOverlayImage"
private let overlayLeftImageName = "noOverlayImage"

class CustomOverlayView: OverlayView {
    
    @IBOutlet var overlayImageView: UIImageView!
    
    override var overlayState: SwipeResultDirection? {
        didSet {
            switch overlayState {
            case .left? :
                overlayImageView.image = UIImage(named: overlayLeftImageName)
            case .right? :
                overlayImageView.image = UIImage(named: overlayRightImageName)
            default:
                overlayImageView.image = nil
            }
        }
    }
    
}
