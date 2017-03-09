//
//  AppCoordinator.swift
//  Flow
//
//  Created by Garric Nahapetian on 1/15/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import UIKit

final class AppCoordinator {
    fileprivate var rootViewController: UINavigationController!
    private var childCoordinators: [Coordinating] = []
    
    func rootViewController(from launchOptions: LaunchOptions) -> UIViewController {
        guard launchOptions == nil else {
            fatalError("LaunchOptions is not nil. Handle launch options in \(#function).")
        }
        return startFeed()
    }
    
    private func startFeed() -> UIViewController {
        
        let fetcher = Fetcher()
        let feedCoordinator = FeedCoordinator(service: fetcher)
        feedCoordinator.delegate = self
        feedCoordinator.start()
        childCoordinators.append(feedCoordinator)
        
        let initialViewController = LoadingVC()
        rootViewController = UINavigationController(rootViewController: initialViewController)
        return rootViewController
    }
}

extension AppCoordinator: ChildCoordinatorDelegate {
    func childCoordinatorIsReady(childCoordinator: Coordinating) {
        switch childCoordinator {
        case is FeedCoordinator: show(childCoordinator.rootViewController)
        default: break
        }
    }
    
    private func show(_ childViewController: UIViewController) {
        rootViewController.viewControllers[0] = childViewController
    }
}
