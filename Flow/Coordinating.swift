//
//  Coordinating.swift
//  Flow
//
//  Created by Garric G. Nahapetian on 3/5/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import UIKit

protocol Coordinating {
    var start: Void { get }
    var rootViewController: UIViewController! { get }
    weak var delegate: ChildCoordinatorDelegate? { get set }
}
