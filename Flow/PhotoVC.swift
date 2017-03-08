//
//  PhotoVC.swift
//  Flow
//
//  Created by Garric G. Nahapetian on 3/5/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import UIKit

final class PhotoVC: UIViewController {
    private let imageView = UIImageView()
    private let photo: Photo
    
    init(photo: Photo) {
        self.photo = photo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(imageView)
        
        imageView.contentMode = .scaleAspectFit
        imageView.image = photo.image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ]
        )
    }
}
