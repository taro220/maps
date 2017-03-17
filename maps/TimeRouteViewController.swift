//
//  TimeRouteViewController.swift
//  maps
//
//  Created by Phill on 3/16/17.
//  Copyright © 2017 Phill. All rights reserved.
//
import UIKit
import CoreData
import CoreLocation
import HealthKit
import MapKit
import AudioToolbox

let DetailSegueName = "RunDetails"

class TimeRouteViewController: UIViewController, CLLocationManagerDelegate {
//    var managedObjectContext: NSManagedObjectContext?
    
//    var run: Run!
    var seconds = 0.0
    var distance = 0.0
    var instantPace = 0.0
    var vertClimb = 0.0
    var vertDescent = 0.0
    var previousAlt = 0.0
    var locationManager: CLLocationManager!
    
    lazy var locations = [CLLocation]()
    lazy var timer = Timer()
    var mapOverlay: MKTileOverlay!
    
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mapView2: MKMapView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
//    @IBOutlet weak var mapView2: MKMapView!
//    @IBOutlet weak var promptLabel: UILabel!
//    @IBOutlet weak var timeLabel: UILabel!
//    @IBOutlet weak var distanceLabel: UILabel!
//    @IBOutlet weak var paceLabel: UILabel!
//    @IBOutlet weak var startButton: UIButton!
//    @IBOutlet weak var stopButton: UIButton!
//    @IBOutlet weak var climbLabel: UILabel!
//    @IBOutlet weak var descentLabel: UILabel!
//    @IBOutlet weak var nextBadgeImageView: UIImageView!
//    @IBOutlet weak var nextBadgeLabel: UILabel!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startButton.isHidden = false
//        promptLabel.isHidden = false
        
        timeLabel.isHidden = true
        distanceLabel.isHidden = true
        speedLabel.isHidden = true
//        climbLabel.isHidden = true
//        descentLabel.isHidden = true
        stopButton.isHidden = true
        mapView2.isHidden = false
//        nextBadgeLabel.isHidden = true
//        nextBadgeImageView.isHidden = true
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        //locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10.0
        locationManager.requestAlwaysAuthorization()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView2.delegate = self;
        
        mapView2.showsUserLocation = true
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let regionRadius: CLLocationDistance = 2000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(mapView2.userLocation.coordinate,regionRadius * 2.0, regionRadius * 2.0)
        mapView2.setRegion(coordinateRegion, animated: true)
    }
    @IBAction func startButtonPressed(_ sender: UIButton) {
        startButton.isHidden = true
        //        promptLabel.isHidden = true
        
        timeLabel.isHidden = false
        distanceLabel.isHidden = false
        speedLabel.isHidden = false
        //        climbLabel.isHidden = false
        //        descentLabel.isHidden = false
        stopButton.isHidden = false
        mapView2.isHidden = false
        //        nextBadgeLabel.isHidden = false
        //        nextBadgeImageView.isHidden = false
        
        seconds = 0.0
        distance = 0.0
        instantPace = 0.0
        locations.removeAll(keepingCapacity: false)
        timer = Timer.scheduledTimer(timeInterval:  1,
                                     target: self,
                                     selector: #selector(eachSecond(_:)),
                                     userInfo: nil,
                                     repeats: true)
        startLocationUpdates()

    }
    @IBAction func startPressed(_ sender: AnyObject) {
        startButton.isHidden = true
//        promptLabel.isHidden = true
        
        timeLabel.isHidden = false
        distanceLabel.isHidden = false
        speedLabel.isHidden = false
//        climbLabel.isHidden = false
//        descentLabel.isHidden = false
        stopButton.isHidden = false
        mapView2.isHidden = false
//        nextBadgeLabel.isHidden = false
//        nextBadgeImageView.isHidden = false
        
        seconds = 0.0
        distance = 0.0
        instantPace = 0.0
        locations.removeAll(keepingCapacity: false)
        timer = Timer.scheduledTimer(timeInterval:  1,
                                     target: self,
                                     selector: #selector(eachSecond(_:)),
                                     userInfo: nil,
                                     repeats: true)
        startLocationUpdates()
    }
    
    @IBAction func endPressed(_ sender: UIButton) {
//        let actionSheet = UIActionSheet(title: "Walk Stopped", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Save", "Discard")
        //        actionSheet.actionSheetStyle = .default
        //        actionSheet.show(in: view)
        locationManager.stopUpdatingLocation()
        timer.invalidate()
    }
    
    @IBAction func stopPressed(_ sender: AnyObject) {
//        let actionSheet = UIActionSheet(title: "Walk Stopped", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Save", "Discard")
//        actionSheet.actionSheetStyle = .default
//        actionSheet.show(in: view)
        locationManager.stopUpdatingLocation()
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let detailViewController = segue.destination as? DetailViewController {
//            detailViewController.run = run
//        }
//    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    
    func eachSecond(_ timer: Timer) {
        seconds += 1
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: Int(seconds))
        let secondsQuantity = HKQuantity(unit: HKUnit.second(), doubleValue: Double(s))
        let minutesQuantity = HKQuantity(unit: HKUnit.minute(), doubleValue: Double(m))
        let hoursQuantity = HKQuantity(unit: HKUnit.hour(), doubleValue: Double(h))
        timeLabel.text = "Time: "+hoursQuantity.description+" "+minutesQuantity.description+" "+secondsQuantity.description
        let distanceQuantity = HKQuantity(unit: HKUnit.mile(), doubleValue: distance)
        distanceLabel.text = "Distance: " + distanceQuantity.description
        
//        speedLabel.text = "Current speed: "+String((instantPace).rounded()/60)+" km/h"//"Pace: "+String((distance/seconds*3.6*10).rounded()/10)+" km/h"
   
        speedLabel.text = "Current speed: "+String(format: "%.3f",self.locations.last!.speed * 2.23694)+" mi/h"//"Pace: "+String((distance/seconds*3.6*10).rounded()/10)+" km/h"
        
//        climbLabel.text = "Total climb: "+String((vertClimb*10).rounded()/10)+" m"
//        descentLabel.text = "Total descent: "+String((vertDescent*10).rounded()/10)+" m"
        
//        checkNextBadge()
//        if let upcomingBadge = upcomingBadge {
//            let nextBadgeDistanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: upcomingBadge.distance! - distance)
//            nextBadgeLabel.text = "\(nextBadgeDistanceQuantity.description) until \(upcomingBadge.name!)"
//            nextBadgeImageView.image = UIImage(named: upcomingBadge.imageName!)
//        }
    }
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
        print("start location update")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            
            let howRecent = location.timestamp.timeIntervalSinceNow
            
            if abs(howRecent) < 10 && location.horizontalAccuracy < 20 {
                //update distance
                if self.locations.count > 0 {
                    distance += location.distance(from: self.locations.last!)/1609.344
                    
                    var coords = [CLLocationCoordinate2D]()
                    coords.append(self.locations.last!.coordinate)
                    coords.append(location.coordinate)
                    
                    instantPace = location.distance(from: self.locations.last!)/(location.timestamp.timeIntervalSince(self.locations.last!.timestamp))
                    
                    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
                    mapView2.setRegion(region, animated: true)
                    
                    mapView2.add(MKPolyline(coordinates: &coords, count: coords.count))
                }
                
                //save location
                self.locations.append(location)
            }
        }
        
    }
    func centerMapOnLocation(location: CLLocation, distance: CLLocationDistance) {
        let regionRadius = distance
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,regionRadius * 2.0, regionRadius * 2.0)
        mapView2.setRegion(coordinateRegion, animated: true)
    }
/*
    func saveRun() {
        // 1
        let savedRun = NSEntityDescription.insertNewObject(forEntityName: "Run",
                                                           into: managedObjectContext!) as! Run
        savedRun.distance = NSNumber(value: distance)
        savedRun.duration = (NSNumber(value: seconds))
        savedRun.timestamp = NSDate() as Date
        savedRun.climb = NSNumber(value: vertClimb)
        savedRun.descent = NSNumber(value: vertDescent)
        
        // 2
        var savedLocations = [Location]()
        for location in locations {
            let savedLocation = NSEntityDescription.insertNewObject(forEntityName: "Location",
                                                                    into: managedObjectContext!) as! Location
            savedLocation.timestamp = location.timestamp
            savedLocation.latitude = NSNumber(value: location.coordinate.latitude)
            savedLocation.longitude = NSNumber(value: location.coordinate.longitude)
            savedLocations.append(savedLocation)
        }
        
        savedRun.locations = NSOrderedSet(array: savedLocations)
        run = savedRun
        
        do{
            try managedObjectContext!.save()
        }catch{
            print("Could not save the run!")
        }
    }
 
 */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        return MKOverlayRenderer()
    }
}
/*
    func checkNextBadge() {
        let nextBadge = BadgeController.sharedController.nextBadgeForDistance(distance: distance)
        
        if let upcomingBadge = upcomingBadge {
            if upcomingBadge.name! != nextBadge.name! {
                playSuccessSound()
            }
        }
        
        upcomingBadge = nextBadge
    }
}

*/
// MARK: UIActionSheetDelegate
/*extension NewRunViewController: UIActionSheetDelegate {
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        //save
        if buttonIndex == 1 {
            saveRun()
            performSegue(withIdentifier: DetailSegueName, sender: nil)
        }
            //discard
        else if buttonIndex == 2 {
            navigationController?.popToRootViewController(animated: true)
        }
    }
}
 */
