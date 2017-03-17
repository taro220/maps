//
//  VCMapView.swift
//  HonoluluArt
//
//  Created by Adrian Yu on 3/16/17.
//  Copyright © 2017 Adrian Yu. All rights reserved.
//

import Foundation
import MapKit

extension UIViewController: MKMapViewDelegate {
    
    //1
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? RoutePin {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: (identifier)) as? MKPinAnnotationView { //2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                //3 code for info button
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y:5)
                view.rightCalloutAccessoryView = UIButton.init(type: .detailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! RoutePin
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
}
