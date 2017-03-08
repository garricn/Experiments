//
//  FeedCoordinator.swift
//  Flow
//
//  Created by Garric Nahapetian on 1/21/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import UIKit

class FeedCoordinator: Coordinating {
    weak var delegate: ChildCoordinatorDelegate?
    private(set) var rootViewController: UIViewController!
    
    private var childCoordinators: [Coordinating] = []
    private let fetcher: Fetcher
    
    init(service: Fetcher) {
        self.fetcher = service
    }
    
    var start: Void {
        fetcher.fetch(with: request, completion: completion)
    }
    
    private var request: URLRequest {
        let query = "https://api.flickr.com/services/rest/?method=flickr.galleries.getPhotos&api_key=\(Private.apiKey)&gallery_id=72157664540660544&format=json&nojsoncallback=1"
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: encoded)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
    
    private func completion(with json: [String: Any]) {
        let dictionary = json["photos"] as? [String: Any] ?? [:]
        let array = dictionary["photo"] as? [[String: Any]] ?? []
        let items = array.flatMap { Photo(json: $0) }
        let feedVC = resolvedFeedVC(for: self, withItems: items)
        rootViewController = feedVC
        DispatchQueue.main.async {
            self.delegate?.childCoordinatorIsReady(childCoordinator: self)
        }
    }
    
    @objc fileprivate func addButtonTapped() {
        let addPhotoVC = resolvedAddPhotoVC(for: self)
        let viewController = UINavigationController(rootViewController: addPhotoVC)
        rootViewController.navigationController?.present(viewController, animated: true)
    }
    
    @objc fileprivate func doneButtonTapped() {
        rootViewController.dismiss(animated: true)
    }
}

extension FeedCoordinator: FeedDelegate {
    func didSelect(_ photo: Photo) {
        let photoVC = PhotoVC(photo: photo)
        photoVC.navigationItem.title = photo.photoID
        addDoneBarButtonItem(to: photoVC)
        let navigationController = UINavigationController(rootViewController: photoVC)
        rootViewController.present(navigationController, animated: true)
    }
    
}

extension FeedCoordinator: AddPhotoDelegate {}

// MARK: - Resolvers

extension FeedCoordinator {
    fileprivate func resolvedFeedVC(for delegate: FeedDelegate, withItems items: [Photo]) -> FeedVC {
        let viewModel = FeedVM(items: items)
        viewModel.delegate = delegate
        
        let feedVC = FeedVC(viewModel: viewModel)
        let rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        feedVC.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        return feedVC
    }
    
    fileprivate func resolvedAddPhotoVC(for delegate: AddPhotoDelegate) -> AddPhotoVC {
        let addPhotoVC = AddPhotoVC()
        addPhotoVC.delegate = self
        addDoneBarButtonItem(to: addPhotoVC)
        return addPhotoVC
    }
    
    fileprivate func addDoneBarButtonItem(to viewController: UIViewController) {
        let buttomItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneButtonTapped)
        )
        viewController.navigationItem.leftBarButtonItem = buttomItem
    }
}

protocol AddPhotoDelegate: class {}

final class AddPhotoVC: UIViewController {
    weak var delegate: AddPhotoDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}
