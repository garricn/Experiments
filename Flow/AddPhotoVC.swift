//
//  AddPhotoVC.swift
//  Flow
//
//  Created by Garric G. Nahapetian on 3/8/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import UIKit

protocol AddPhotoDelegate: class {}

final class AddPhotoVC: UIViewController {
    weak var delegate: AddPhotoDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}
