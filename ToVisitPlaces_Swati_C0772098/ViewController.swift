//
//  ViewController.swift
//  findMyWay_Lab_assignment_1
//
//  Created by user173890 on 6/12/20.
//  Copyright © 2020 user173890. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    var transporttype: MKDirectionsTransportType = .automobile

    @IBOutlet weak var uiswitch: UISwitch!
    
    @IBOutlet weak var typelabel: UILabel!
    let locationManager = CLLocationManager()
    var coordinates: CLLocationCoordinate2D?
    var place: Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        addDoubleTapGesture()
        if place != nil
        {
            let annotation = MKPointAnnotation()
            annotation.title = place!.title
            annotation.coordinate = CLLocationCoordinate2D(latitude: place!.latitude, longitude: place!.longitude)
            coordinates = annotation.coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    func addDoubleTapGesture()
    {
        let tap = UITapGestureRecognizer(target: self, action: #selector(addAnnotation))
        tap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(tap)
    }
    
    @objc func addAnnotation(gestureRecognizer:UITapGestureRecognizer){
        let touchPoint = gestureRecognizer.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        coordinates = newCoordinates
        annotation.title = "Destination"
        mapView.addAnnotation(annotation)
    }
    
    
    @IBAction func navigateTapped(_ sender: Any) {
        if locationManager.location?.coordinate != nil && coordinates != nil
        {
            let location = locationManager.location!.coordinate
            let destination = CLLocation(latitude: coordinates!.latitude, longitude: coordinates!.longitude)
            let request = MKDirections.Request()
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinates!))
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: location))
            request.transportType = transporttype
            request.requestsAlternateRoutes = false
            let directions = MKDirections(request: request)
            directions.calculate { [unowned self] (response, error) in
                print("1")
                guard let response = response else
                {
                    
                    return
                }
                
                for route in response.routes
                {
                    print("2")
                    self.mapView.addOverlay(route.polyline)
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                }
            }
        }
    }
    
    func setupLocationManager(){
        locationManager.delegate = self //set delegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //for the accurate location
    }
    
    func centerViewOnUserLocation(){
        if let Location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: Location, latitudinalMeters: 10000, longitudinalMeters: 10000)
            mapView.setRegion(region, animated: true)
        }
    }
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        }
        else{
            // show alert letting the user know they have to turn the location on
        }
    }
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus() {
            
        case .authorizedWhenInUse:
            //Map
            //startTrackingUserLocation()
            break
        case .denied:
            //show alert to allow the access of location
            break
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // show the alert to the user that whats going on
            break
            
        case .authorizedAlways:
            break
            
            
        @unknown default:
            break
        }}
    
    
    @IBAction func findMyWayClicked(_ sender: Any) {
        centerViewOnUserLocation()
    }
    //func startTrackingUserLocation(){
    //    mapView.showsUserLocation = true // shows user's location
    //    centerViewOnUserLocation()
    //   locationManager.startUpdatingLocation()//to update the locationof the user
    //    previousLocation = getCenterLocation(for: mapView)
    //}
    
    
    
    @IBAction func valueChanged(_ sender: Any) {
        if uiswitch.isOn
        {
            transporttype = .automobile
            typelabel.text = "Automobile"
        }
        else
        {
            typelabel.text = "Walking"
            transporttype = .walking
        }
    }
    
}
extension ViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("3")
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .darkGray
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        let pinAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin") ?? MKPinAnnotationView()
        pinAnnotation.image = UIImage(named: "ic_place")
        pinAnnotation.centerOffset = CGPoint(x: 0,y: -(pinAnnotation.image?.size.height ?? 0)/2)
        pinAnnotation.canShowCallout = true
        let btn = UIButton(type: .detailDisclosure)
        pinAnnotation.rightCalloutAccessoryView = btn
        return pinAnnotation
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: view.annotation!.coordinate.latitude, longitude: view.annotation!.coordinate.longitude), completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription )
                return
            }
            
            var places: [Place]! = self.getPlaces() ?? []
            let title = (placemarks?.first?.subThoroughfare ?? "") + " " + (placemarks?.first?.thoroughfare ?? "")
            places.append(Place(longitude: view.annotation!.coordinate.longitude, latitude: view.annotation!.coordinate.latitude, title: title))
            self.savePlaces(places: places)
            let alert = UIAlertController(title: "Place Added", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "okay", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        })
        
    }
    
    func savePlaces(places: [Place])
    {
        do
        {
            let encoder = JSONEncoder()
            let data = try encoder.encode(places)
            UserDefaults.standard.set(data, forKey: "places")
        } catch {
            print("Unable to Encode Array of Notes (\(error))")
        }
    }
    
    func getPlaces() -> [Place]?
    {
        if let data = UserDefaults.standard.data(forKey: "places")
        {
            do {
                let decoder = JSONDecoder()
                let places = try decoder.decode([Place].self, from: data)
                return places
            } catch {
                print("Unable to Decode Notes (\(error))")
            }
        }
        return nil
    }
}

