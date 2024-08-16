//
//  PhotoViewController.swift
//  MobileUPIntership
//
//  Created by Denis Raiko on 15.08.24.
//

import UIKit

class PhotoViewController: UIViewController {
    
    private var photos: [Photo] = []

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        
        let numberOfItemsInRow: CGFloat = 2
        let padding: CGFloat = 4
        let totalPadding = padding * (numberOfItemsInRow - 1)
        let itemWidth = (UIScreen.main.bounds.width - totalPadding) / numberOfItemsInRow

        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        loadAlbums()
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func loadAlbums() {
        guard let token = UserDefaults.standard.string(forKey: "vk_access_token") else { return }

        let ownerId = "-128666765"
        let version = "5.131"

        let urlString = "https://api.vk.com/method/photos.getAlbums?owner_id=\(ownerId)&access_token=\(token)&v=\(version)"

        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let response = json["response"] as? [String: Any],
                   let items = response["items"] as? [[String: Any]] {

                    let albumIds = items.compactMap { $0["id"] as? Int }

                    // Загружаем фотографии для каждого альбома
                    for albumId in albumIds {
                        self?.loadPhotos(for: albumId)
                    }
                }
            } catch {
                print("Ошибка при обработке JSON: \(error.localizedDescription)")
            }
        }

        task.resume()
    }

    private func loadPhotos(for albumId: Int, offset: Int = 0) {
        guard let token = UserDefaults.standard.string(forKey: "vk_access_token") else { return }

        let ownerId = "-128666765"
        let version = "5.131"

        let urlString = "https://api.vk.com/method/photos.get?owner_id=\(ownerId)&album_id=\(albumId)&count=200&offset=\(offset)&access_token=\(token)&v=\(version)"

        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let response = json["response"] as? [String: Any],
                   let items = response["items"] as? [[String: Any]] {

                    let newPhotos: [Photo] = items.compactMap { item in
                        guard let sizes = item["sizes"] as? [[String: Any]],
                              let date = item["date"] as? TimeInterval,
                              let url = sizes.last?["url"] as? String else { return nil }
                        return Photo(url: url, date: Date(timeIntervalSince1970: date))
                    }

                    DispatchQueue.main.async {
                        self?.photos.append(contentsOf: newPhotos)
                        self?.collectionView.reloadData()
                    }
                }
            } catch {
                print("Ошибка при обработке JSON: \(error.localizedDescription)")
            }
        }

        task.resume()
    }
}

extension PhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        let photo = photos[indexPath.item]
        cell.configure(with: photo)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photos[indexPath.item]
        let detailVC = PhotoDetailViewController(photo: photo)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
