//
//  MapsViewController.swift
//  maps
//
//  Created by Phill on 3/16/17.
//  Copyright © 2017 Phill. All rights reserved.
//

import Foundation

import UIKit
import MapKit
import HealthKit
import CoreLocation
import CoreData

class MapsViewController: UIViewController, CLLocationManagerDelegate {
    

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = CLActivityType.automotiveNavigation
        _locationManager.distanceFilter = 1000.0
        
        return _locationManager
    }()
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    lazy var locations = [CLLocation]()
    lazy var timer = Timer()
    var seconds = 0.0
    var distance = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationAuthorizationStatus()
        
        locationManager.delegate = self
        ///////
        mapView.delegate = self
        let route_pin = RoutePin(title: "Redwood Entrance", locationName: "Redwood 1", discipline: "Route", coordinate: CLLocationCoordinate2D(latitude: 37.800322, longitude: -122.170535))
        mapView.addAnnotation(route_pin)
        
        let route_pin2 = RoutePin(title: "Redwood Exit", locationName: "Redwood 2", discipline: "Route", coordinate: CLLocationCoordinate2D(latitude: 37.724927, longitude: -122.079789))
        mapView.addAnnotation(route_pin2)
        
        
        let sourceLocation = route_pin.coordinate
        let destinationLocation = route_pin2.coordinate
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        //        let sourceAnnotation = MKPointAnnotation()
        //        sourceAnnotation.title = "Redwood Entrance"
        //        if let location = sourcePlacemark.location {
        //            sourceAnnotation.coordinate = location.coordinate
        //        }
        //        let destinationAnnotation = MKPointAnnotation()
        //        destinationAnnotation.title = "Redwood Exit"
        
        //        if let location = destinationPlacemark.location {
        //            destinationAnnotation.coordinate = location.coordinate
        //        }
        self.mapView.showAnnotations([route_pin,route_pin2], animated: true )
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        let directions = MKDirections(request: directionRequest)
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
        
        ////////
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        locationManager.distanceFilter = kCLDistanceFilterNone
        //        locationManager.startUpdatingLocation()
        
    }
    
    
    
    
    
    
    ////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    ///////////////////////////////////////////
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    func startLocationUpdates() {
        // Here, the location manager will be lazily instantiated
        locationManager.startUpdatingLocation()
    }
    
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        seconds = 0.0
        distance = 0.0
        locations.removeAll(keepingCapacity: false)
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: "eachSecond:",
                                     userInfo: nil,
                                     repeats: true)
        startLocationUpdates()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let loc = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        centerMapOnLocation(location: loc)
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    /////////////////////////////
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    
    func eachSecond(_ timer: Timer) {
        seconds += 1
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: Int(seconds))
        let secondsQuantity = HKQuantity(unit: HKUnit.second(), doubleValue: Double(s))
        let minutesQuantity = HKQuantity(unit: HKUnit.minute(), doubleValue: Double(m))
        let hoursQuantity = HKQuantity(unit: HKUnit.hour(), doubleValue: Double(h))
        //        timeLabel.text = "Time: "+hoursQuantity.description+" "+minutesQuantity.description+" "+secondsQuantity.description
        let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: distance)
        //        distanceLabel.text = "Distance: " + distanceQuantity.description
        
        //        paceLabel.text = "Current speed: "+String((instantPace*3.6*10).rounded()/10)+" km/h"//"Pace: "+String((distance/seconds*3.6*10).rounded()/10)+" km/h"
        
        //        climbLabel.text = "Total climb: "+String((vertClimb*10).rounded()/10)+" m"
        //        descentLabel.text = "Total descent: "+String((vertDescent*10).rounded()/10)+" m"
    }
    ////////////////////
    
    
    
    
}





