//
//  HomeViewController.swift
//  Tweets
//
//  Created by Sergio Carralero Nuño on 8/4/21.
//

import UIKit
import Simple_Networking
import SVProgressHUD
import NotificationBannerSwift
import AVKit

class HomeViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addPostButton: UIButton!
    
    // MARK: - Properties
    private let cellId = "TweetTableViewCell"
    private var dataSource = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getPosts()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        // 1. Asign data source
        // 2. Register cell
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
        
        addPostButton.layer.cornerRadius = 25
    }
    
    private func getPosts() {
        // Show loader
        SVProgressHUD.show()
        
        // Call service
        SN.get(endpoint: Endpoints.getPosts) { (response: SNResultWithEntity<[Post], ErrorResponse>) in
            SVProgressHUD.dismiss()
            
            switch response {
                case .success(let posts):
                    self.dataSource = posts
                    self.tableView.reloadData()
                case .error(let error):
                    NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: .danger).show()
                case .errorResult(let entity):
                    NotificationBanner(title: "Error", subtitle: entity.error, style: .warning).show()
            }
        }
    }
    
    private func deletePostAt(indexPath: IndexPath) {
        // 1. Show loader
        SVProgressHUD.show()
        
        // 2. Get post ID to delete
        let postId = dataSource[indexPath.row].id
        
        // 3. Preparing delete endpoint
        let endpoint = Endpoints.delete + postId
        
        // 4. Call service to delete post
        SN.delete(endpoint: endpoint) { (response: SNResultWithEntity<GeneralResponse, ErrorResponse>) in
            // Close loader
            SVProgressHUD.dismiss()
            
            switch response {
            case .success:
                // 1. Delete post from datasource
                self.dataSource.remove(at: indexPath.row)
                
                // 2. Delete table cell
                self.tableView.deleteRows(at: [indexPath], with: .left)
                
            case .error(let error):
                NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: .danger).show()
            case .errorResult(let entity):
                NotificationBanner(title: "Error", subtitle: entity.error, style: .warning).show()
            }
            
        }
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, _) in
            // Now we delete the tweet
            self.deletePostAt(indexPath: indexPath)
        }
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Get email saved in UserDefaults
        let storedEmail = UserDefaults.standard.string(forKey: "email-saved")
        
        // Only allow to delete own posts
        return dataSource[indexPath.row].author.email == storedEmail
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Total cells
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        if let cell = cell as? TweetTableViewCell {
            // Configure cell
            cell.setupCellWith(post: dataSource[indexPath.row])
            cell.needsToShowVideo = { url in
                // Now we need to open ViewController
                let avPlayer = AVPlayer(url: url)
                let avPlayerController = AVPlayerViewController()
                avPlayerController.player = avPlayer
                
                self.present(avPlayerController, animated: true) {
                    avPlayerController.player?.play()
                }
            }
        }
        
        return cell
    }
}

// MARK: -Navigation
extension HomeViewController {
    // This method is called when we have transitions between screens (only with storyboards)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 1. Validate we got the expected segue
        if segue.identifier == "showMap", let mapViewController = segue.destination as? MapViewController {
            // Now we know we will go to the Map screen. We can obtain the posts with location
            mapViewController.posts = dataSource.filter { $0.hasLocation }
        }
    }
}
