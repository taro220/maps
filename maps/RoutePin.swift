//
//  RoutePin.swift
//  maps
//
//  Created by Phill on 3/16/17.
//  Copyright © 2017 Phill. All rights reserved.
//

import UIKit
import MapKit
import Contacts

class RoutePin: NSObject, MKAnnotation {
    let title: String?
    let locationName:  String
    let discpline: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discpline = discipline
        self.coordinate = coordinate
        super.init()
    }
    var subtitle: String? {
        return locationName
    }
    
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(CNPostalAddressStreetKey): subtitle]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        
        
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }

}
