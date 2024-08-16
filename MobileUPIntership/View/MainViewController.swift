//
//  MainViewController.swift
//  MobileUPIntership
//
//  Created by Denis Raiko on 15.08.24.
//

import UIKit
import WebKit

class MainViewController: UIViewController {
    
    private let segmentControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Фото", "Видео"])
        control.selectedSegmentIndex = 0
        control.layer.cornerRadius = 8
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let photoViewController = PhotoViewController()
    private let videoViewController = VideoViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupSegmentControl()
        setupUI()
        setupNavigationBar()
        
        
        
    }
    
    private func setupNavigationBar() {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        title = "Mobile UP Gallery"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let logoutButton = UIBarButtonItem(title: "Выход", style: .plain, target: self, action: #selector(logoutTapped))
        let buttonAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular),
            .foregroundColor: UIColor.black
        ]
        logoutButton.setTitleTextAttributes(buttonAttributes, for: .normal)
        navigationItem.rightBarButtonItem = logoutButton
    }
    
    private func setupSegmentControl() {
        view.addSubview(segmentControl)
        
        NSLayoutConstraint.activate([
            segmentControl.widthAnchor.constraint(equalToConstant: 343),
            segmentControl.heightAnchor.constraint(equalToConstant: 32),
            
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        segmentControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
    }
    
    private func setupUI() {
        addChild(photoViewController)
        addChild(videoViewController)
        
        view.addSubview(photoViewController.view)
        view.addSubview(videoViewController.view)
        
        photoViewController.didMove(toParent: self)
        videoViewController.didMove(toParent: self)
        
        photoViewController.view.translatesAutoresizingMaskIntoConstraints = false
        videoViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            photoViewController.view.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 20),
            photoViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            photoViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photoViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            videoViewController.view.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 20),
            videoViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            videoViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        videoViewController.view.isHidden = true
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            photoViewController.view.isHidden = false
            videoViewController.view.isHidden = true
        } else {
            photoViewController.view.isHidden = true
            videoViewController.view.isHidden = false
        }
    }
    
    @objc private func logoutTapped() {
        UserDefaults.standard.removeObject(forKey: "vk_access_token")
        
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            for record in records {
                if record.displayName.contains("vk.com") {
                    dataStore.removeData(ofTypes: record.dataTypes, for: [record]) {
                        print("Сессия ВКонтакте успешно сброшена")
                    }
                }
            }
            
            if let window = UIApplication.shared.windows.first {
                let authViewController = WelcomeViewController()
                let navigationController = UINavigationController(rootViewController: authViewController)
                window.rootViewController = navigationController
                window.makeKeyAndVisible()
            }
        }
    }
}
