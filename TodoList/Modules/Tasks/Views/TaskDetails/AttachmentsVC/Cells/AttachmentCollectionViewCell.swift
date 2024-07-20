//
//  AttachmentCollectionViewCell.swift
//  TodoList
//
//  Created by Jayant Karthic on 16/07/24.
//


import UIKit

class AttachmentCollectionViewCell: UICollectionViewCell {

    let imageView = UIImageView()
    let deleteButton = UIButton(type: .system)
    let containerView = UIView()
    let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(deleteButton)
        containerView.addSubview(nameLabel)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: nameLabel.topAnchor),

            nameLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 5),
            nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -5),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),
            nameLabel.heightAnchor.constraint(equalToConstant: 40),

            deleteButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            deleteButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -5),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24)
        ])

        containerView.layer.cornerRadius = 10
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.masksToBounds = false

        containerView.backgroundColor = .white
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true

        deleteButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        deleteButton.tintColor = .opaqueSeparator
        
        deleteButton.backgroundColor = .clear // Updated to opaque separator color
        deleteButton.layer.cornerRadius = 12
        deleteButton.layer.masksToBounds = true

        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        nameLabel.font = UIFont.systemFont(ofSize: 12)
    }

    func configure(with url: URL) {
        nameLabel.text = url.lastPathComponent
        if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
            imageView.image = image
        } else {
            imageView.image = UIImage(systemName: "doc")
        }
    }
}
