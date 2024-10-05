//
//  MapController.swift
//  CambourneCrescent
//
//  Created by Ahmed, Shakeel on 27/07/2024.
//

import UIKit
import MapKit
import CoreLocation

class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager?
    enum Location {
        case hub
        case NCP
        case BlueSchool
        case cvc
        case lcp
        case sp
    }
    
    public var location: Location = .hub
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = "Salah Location"
      
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        
        let place = MKPointAnnotation()
        switch location {
        case .hub:
            place.title = "HUB"
            let coordinates = CLLocationCoordinate2D(latitude: 52.218645, longitude: -0.064183)
            place.coordinate = coordinates
            mapView.setRegion(
                MKCoordinateRegion(
                    center: coordinates,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ),
                animated: true
            )
        case .NCP:
            place.title = "NCP"
            let coordinates = CLLocationCoordinate2D(latitude: 52.218862, longitude: -0.059262)
            place.coordinate = coordinates
            mapView.setRegion(
                MKCoordinateRegion(
                    center: coordinates,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ),
                animated: true
            )
        case .BlueSchool:
            place.title = "BS-H"
            let coordinates = CLLocationCoordinate2D(latitude: 52.219000, longitude: -0.061699)
            place.coordinate = coordinates
            mapView.setRegion(
                MKCoordinateRegion(
                    center: coordinates,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ),
                animated: true
            )
        case .cvc:
            place.title = "CVC"
            let coordinates = CLLocationCoordinate2D(latitude: 52.222621, longitude: -0.084119)
            place.coordinate = coordinates
            mapView.setRegion(
                MKCoordinateRegion(
                    center: coordinates,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ),
                animated: true
            )
        case .lcp:
            place.title = "LCP"
            let coordinates = CLLocationCoordinate2D(latitude: 52.217372, longitude: -0.082796)
            place.coordinate = coordinates
            mapView.setRegion(
                MKCoordinateRegion(
                    center: coordinates,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ),
                animated: true
            )
        case .sp:
            place.title = "SP"
            let coordinates = CLLocationCoordinate2D(latitude: 52.221497, longitude: -0.060478)
            place.coordinate = coordinates
            mapView.setRegion(
                MKCoordinateRegion(
                    center: coordinates,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ),
                animated: true
            )
        }
        mapView.addAnnotation(place)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }

        return annotationView
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
