//
//  Restaurants+CoreDataProperties.swift
//  
//
//  Created by admin on 2/18/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Restaurants {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Restaurants> {
        return NSFetchRequest<Restaurants>(entityName: "Restaurants");
    }

    @NSManaged public var businessid: String?
    @NSManaged public var name: String?
    @NSManaged public var category: String?
    @NSManaged public var latitude : Double?
    @NSManaged public var longitude : Double?
}
