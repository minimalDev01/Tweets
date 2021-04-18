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
    private var posts = [Post]()
    private var map: MKMapView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
    }
    
    // MARK: -Private func
    private func setupMap() {
        map = MKMapView(frame: mapContainer.bounds)
        mapContainer.addSubview(map ?? UIView())
    }
}
