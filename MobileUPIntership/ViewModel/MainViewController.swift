//
//  MainViewController.swift
//  MobileUPIntership
//
//  Created by Denis Raiko on 15.08.24.
//

import UIKit

class MainViewController: UIViewController {
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Photos", "Videos"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let photoViewController = PhotoViewController()
    private let videoViewController = VideoViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSegmentedControl()
        showContent(for: 0)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.titleView = segmentedControl
        
        // Добавляем контейнер для контента
        addChild(photoViewController)
        addChild(videoViewController)
        
        view.addSubview(photoViewController.view)
        view.addSubview(videoViewController.view)
        
        photoViewController.view.translatesAutoresizingMaskIntoConstraints = false
        videoViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            photoViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            photoViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            photoViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photoViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            videoViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            videoViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            videoViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        videoViewController.view.isHidden = true
    }
    
    private func setupSegmentedControl() {
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        showContent(for: sender.selectedSegmentIndex)
    }
    
    private func showContent(for index: Int) {
        photoViewController.view.isHidden = index != 0
        videoViewController.view.isHidden = index != 1
    }
}
