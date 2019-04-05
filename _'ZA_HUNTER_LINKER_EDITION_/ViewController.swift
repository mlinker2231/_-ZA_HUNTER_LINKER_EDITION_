//
//  ViewController.swift
//  _'ZA_HUNTER_LINKER_EDITION_
//
//  Created by Michael Linker on 4/3/19.
//  Copyright © 2019 Michael Linker. All rights reserved.
//

import UIKit
import MapKit
import SafariServices
import Contacts
class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var pizzaPlaces: [MKMapItem] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        currentLocation = locationManager.location
        mapView.delegate = self
    }
    @IBAction func whenZoomButtonPressed(_ sender: Any) {
        let center = currentLocation.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    @IBAction func whenSearchButtonPressed(_ sender: Any) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "pizza"
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        request.region = MKCoordinateRegion(center: currentLocation.coordinate, span: span)
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else {
                return
            }
            
            for mapItem in response.mapItems {
                self.pizzaPlaces.append(mapItem)
                let annotaion = MKPointAnnotation()
                
                annotaion.coordinate = mapItem.placemark.coordinate
                annotaion.title = mapItem.name
                self.mapView.addAnnotation(annotaion)
            }
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isEqual(mapView.userLocation) {
            return nil
        }
        let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pin.image = UIImage.init(named: "hi")
        pin.canShowCallout = true
        let button = UIButton(type: .infoLight)
        pin.rightCalloutAccessoryView = button
        return pin
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        var currentMapItem = MKMapItem()
        if let title = view.annotation?.title,let pizza = title {
            for mapItem in pizzaPlaces {
                if mapItem.name == pizza {
                    currentMapItem = mapItem
                }
            }
        }
        CLGeocoder().reverseGeocodeLocation(currentMapItem.placemark.location!, preferredLocale: nil) { (clPlacemark: [CLPlacemark]?, error: Error?) in
            guard let place = clPlacemark?.first else {
                print("No placemark from Apple: \(String(describing: error))")
                return
            }
            
            let postalAddressFormatter = CNPostalAddressFormatter()
            postalAddressFormatter.style = .mailingAddress
            var addressString: String?
            if let postalAddress = place.postalAddress {
                addressString = postalAddressFormatter.string(from: postalAddress)
            }
            let alert = UIAlertController(title: "\(currentMapItem.name!)", message: addressString, preferredStyle: .alert)
            self.present(alert, animated: true)
        }
//        let alert = UIAlertController(title: "\(currentMapItem.name!)", message: addressString, preferredStyle: .alert)
//        present(alert, animated: true)
    }
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    currentLocation = locations[0]
    print(currentLocation)
    }
}
