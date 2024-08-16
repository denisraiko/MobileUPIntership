//
//  PhotoDetailViewController.swift
//  MobileUPIntership
//
//  Created by Denis Raiko on 15.08.24.
//

import UIKit

class PhotoDetailViewController: UIViewController {
    private let photo: Photo
    private let imageView = UIImageView()
    private var image: UIImage?

    init(photo: Photo) {
        self.photo = photo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadImage()
        setupNavigationBar()
    }
    
    private func setupUI() {
        title = DateFormatter.localizedString(from: photo.date, dateStyle: .medium, timeStyle: .none)
        view.backgroundColor = .white
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .black
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        navigationItem.rightBarButtonItem = shareButton
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    private func loadImage() {
        guard let url = URL(string: photo.url) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.imageView.image = image
                self?.image = image
            }
        }.resume()
    }
    
    @objc private func shareTapped() {
        guard let image = image else { return }
        
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { [weak self] activityType, completed, _, error in
            if completed {
                if activityType == nil || activityType == .saveToCameraRoll {
                    self?.showAlert(title: "Сохранено!", message: "Изображение успешно сохранено в галерею")
                }
            } else {
                print("Изображение не сохранено: \(String(describing: activityType))")
            }
        }
        present(activityVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
