//
//  PhotoCell.swift
//  MobileUPIntership
//
//  Created by Denis Raiko on 15.08.24.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with photo: Photo) {
        imageView.image = nil // Сбросить изображение перед повторным использованием ячейки

        // Кэширование изображений
        if let cachedImage = ImageCache.shared.object(forKey: NSString(string: photo.url)) {
            imageView.image = cachedImage
            return
        }
        
        // Загрузка изображения
        guard let url = URL(string: photo.url) else { return }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else { return }
            
            // Сохранить изображение в кэше
            ImageCache.shared.setObject(image, forKey: NSString(string: photo.url))
            
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
        task.resume()
    }
}
