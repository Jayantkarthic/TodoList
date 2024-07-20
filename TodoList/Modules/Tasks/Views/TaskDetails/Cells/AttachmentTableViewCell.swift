//
//  AttachmentTableViewCell.swift
//  TodoList
//
//  Created by Jayant Karthic on 20/07/24.
//



import UIKit

protocol AttachmentTableViewCellDelegate: AnyObject {
    func didSelectAttachment(_ url: URL)
    func deleteAttachment(at index: Int)
}

class AttachmentTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    private let collectionView: UICollectionView
    private var attachmentURLs: [URL] = []
    weak var delegate: AttachmentTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 130)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(AttachmentCollectionViewCell.self, forCellWithReuseIdentifier: "AttachmentCell")
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            collectionView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    func configure(with attachmentURLs: [URL]) {
        self.attachmentURLs = attachmentURLs
        collectionView.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachmentURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AttachmentCell", for: indexPath) as! AttachmentCollectionViewCell
        let url = attachmentURLs[indexPath.row]
        cell.configure(with: url)
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteAttachment), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let url = attachmentURLs[indexPath.row]
        delegate?.didSelectAttachment(url)
    }
    
    @objc private func deleteAttachment(sender: UIButton) {
        let index = sender.tag
        delegate?.deleteAttachment(at: index)
    }
    
}
