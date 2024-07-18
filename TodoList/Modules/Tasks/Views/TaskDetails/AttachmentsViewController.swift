//
//  AttachmentsViewController.swift
//  TodoList
//
//  Created by Jayant Karthic on 16/07/24.
//

import UIKit
import QuickLook

class AttachmentsViewController: UIViewController {
    
    var attachmentURLs: [URL] = []
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "Attachments"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AttachmentCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

//  MARK: - UITableViewDataSource & UITableViewDelegate
extension AttachmentsViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attachmentURLs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentCell", for: indexPath)
        let url = attachmentURLs[indexPath.row]
        cell.textLabel?.text = url.lastPathComponent
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.currentPreviewItemIndex = indexPath.row
        present(previewController, animated: true, completion: nil)
    }
    
}
// MARK: - QLPreviewControllerDataSource
extension AttachmentsViewController : QLPreviewControllerDataSource{
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return attachmentURLs.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return attachmentURLs[index] as QLPreviewItem
    }
    
}
