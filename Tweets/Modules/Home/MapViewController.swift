//
//  MapViewController.swift
//  Tweets
//
//  Created by Sergio Carralero Nuño on 18/4/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    // MARK: -IBOutlets
    @IBOutlet weak var mapContainer: UIView!
    
    // MARK: -Properties
    var posts = [Post]()
    private var map: MKMapView?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // If we use bounds instead of a number for a size, we need to call them into viweDidAppear for fullscreen
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupMap()
    }
    
    // MARK: -Private func
    private func setupMap() {
        map = MKMapView(frame: mapContainer.bounds)
        mapContainer.addSubview(map ?? UIView())
        
        setupMarkers()
    }
    
    private func setupMarkers() {
        posts.forEach { item in
            let marker = MKPointAnnotation()
            marker.coordinate = CLLocationCoordinate2D(latitude: item.location.latitude, longitude: item.location.longitude)
            
            marker.title = item.text
            marker.subtitle = item.author.names
            
            map?.addAnnotation(marker)
        }
        
        // Searching last post of array
        guard let lastPost = posts.last else {
            return
        }
        
        // Now we are going to show the position of our last tweet
        let lastPostLocation = CLLocationCoordinate2D(latitude: lastPost.location.latitude, longitude: lastPost.location.longitude)
        
        guard let heading = CLLocationDirection(exactly: 12) else {
            return
        }
        map?.camera = MKMapCamera(lookingAtCenter: lastPostLocation, fromDistance: 30, pitch: .zero, heading: heading)
    }
}
