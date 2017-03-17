//
//  ViewController.swift
//  maps
//
//  Created by Phill on 3/16/17.
//  Copyright © 2017 Phill. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController {
    var managedObjectContext: NSManagedObjectContext?

//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: MapsViewController.self) {
            if let mapsViewController = segue.destination as? MapsViewController {
//                mapsViewController.managedObjectContext = managedObjectContext
            } else if segue.destination.isKind(of: TimeRouteViewController.self) {
                if let timeRouteViewController = segue.destination as? TimeRouteViewController {
                    //                mapsViewController.managedObjectContext = managedObjectContext
                }
            }
        }
}
}

