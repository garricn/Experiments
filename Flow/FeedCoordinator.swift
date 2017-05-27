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
    
    fileprivate var selectedPhoto: Photo?
    private var childCoordinators: [Coordinating] = []
    private let fetcher: Fetcher

    init(service: Fetcher) {
        self.fetcher = service
    }
    
    func start() {
        fetcher.fetch(with: request, completion: completion)
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
    
    // MARK: - Interactivity
    
    @objc fileprivate func addButtonTapped() {
        let addPhotoCoordinator = AddPhotoCoordinator()
        addPhotoCoordinator.delegate = self
        addPhotoCoordinator.start()
        childCoordinators.append(addPhotoCoordinator)
    }
    
    @objc fileprivate func doneButtonTapped() {
        rootViewController.dismiss(animated: true)
    }
    
    @objc fileprivate func actionButtonTapped() {
        guard let image = selectedPhoto?.image else { return }
        
        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        rootViewController.present(activityViewController, animated: true)
    }
}

extension FeedCoordinator: ChildCoordinatorDelegate {
    func childCoordinatorIsReady(childCoordinator: Coordinating) {
        if let viewController = childCoordinator.rootViewController {
            addDoneBarButtonItem(to: viewController)
            let navigationController = UINavigationController(rootViewController: viewController)
            rootViewController.present(navigationController, animated: true)
        }
    }
}


final class AddPhotoCoordinator: Coordinating {
    weak var delegate: ChildCoordinatorDelegate?
    var rootViewController: UIViewController!

    func start() {
        rootViewController = AddPhotoVC()
        rootViewController.view.backgroundColor = .yellow
        delegate?.childCoordinatorIsReady(childCoordinator: self)
    }
}

extension FeedCoordinator: FeedDelegate {
    func didSelect(_ photo: Photo) {
        selectedPhoto = photo
        
        let viewPhotoVC = ViewPhotoVC(photo: photo)
        viewPhotoVC.navigationItem.title = photo.photoID
        
        addDoneBarButtonItem(to: viewPhotoVC)
        addActionBarButtonItem(to: viewPhotoVC)
        
        let navigationController = UINavigationController(rootViewController: viewPhotoVC)

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
}

// MARK: - Helpers

extension FeedCoordinator {
    fileprivate func addDoneBarButtonItem(to viewController: UIViewController) {
        let buttomItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneButtonTapped)
        )
        viewController.navigationItem.rightBarButtonItem = buttomItem
    }
    
    fileprivate func addActionBarButtonItem(to viewController: UIViewController) {
        let item = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(actionButtonTapped)
        )
        viewController.navigationItem.leftBarButtonItem = item
    }
    
    fileprivate var request: URLRequest {
        let query = "https://api.flickr.com/services/rest/?method=flickr.galleries.getPhotos&api_key=\(Private.apiKey)&gallery_id=72157664540660544&format=json&nojsoncallback=1"
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: encoded)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
}
