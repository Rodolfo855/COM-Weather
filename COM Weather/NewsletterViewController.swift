//
//  NewsletterViewController.swift
//  COM Weather
//
//  Created by Victor Rosales  on 2/14/26.
//

import UIKit
import SwiftUI
import AVKit
import AVFoundation

struct NewsletterViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let nav = UINavigationController(rootViewController: NewsletterViewController())
        nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        return nav
    }
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

class NewsletterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let tableView = UITableView()
    let items = [
        ("video", "STUDENT LIFE", "Spring Festival", "Buzzing today!", "sunny", "Campus Bookstore"),
        ("image", "ACADEMICS", "Library Update", "New study pods.", "banner1", "Fusselman Hall"),
        ("image", "SPORTS", "Soccer Victory", "Mariners won!", "image5", "Athletic Field")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Campus Feed"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        
        // Forced White/Light Background to match Live Weather
        view.backgroundColor = UIColor(white: 0.94, alpha: 1.0)
        
        tableView.dataSource = self; tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.register(FeedCell.self, forCellReuseIdentifier: "FeedCell")
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
    }
    
    @objc func dismissVC() { dismiss(animated: true) }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        let i = items[indexPath.row]
        cell.configure(tag: i.1, title: i.2, body: i.3, imgName: i.4, isVideo: i.0 == "video", loc: i.5)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if items[indexPath.row].0 == "video" { playVideo(named: "testVideo") }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func playVideo(named name: String) {
        let videoURL = Bundle.main.url(forResource: name, withExtension: "mp4") ?? URL(string: "https://web.archive.org/web/20230526183015/https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4")!
        let player = AVPlayer(url: videoURL)
        let pc = AVPlayerViewController()
        pc.player = player
        present(pc, animated: true) { player.play() }
    }
}

class FeedCell: UITableViewCell {
    let card = UIView()
    let shadowContainer = UIView() // Added for consistent shadows
    let iv = UIImageView()
    let play = UIImageView(image: UIImage(systemName: "play.circle.fill"))
    let tagL = UILabel(); let titleL = UILabel(); let bodyL = UILabel()
    let locBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    let locL = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier); setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    func setup() {
        selectionStyle = .none; backgroundColor = .clear
        card.backgroundColor = .white; card.layer.cornerRadius = 20; card.clipsToBounds = true
        
        // Consistent Bold Shadow
        shadowContainer.backgroundColor = .clear
        shadowContainer.layer.shadowColor = UIColor.black.cgColor
        shadowContainer.layer.shadowOpacity = 0.45
        shadowContainer.layer.shadowOffset = CGSize(width: 0, height: 10)
        shadowContainer.layer.shadowRadius = 15
        shadowContainer.layer.masksToBounds = false

        iv.contentMode = .scaleAspectFill; iv.clipsToBounds = true; iv.layer.cornerRadius = 15
        play.tintColor = .white
        locBlur.layer.cornerRadius = 6; locBlur.clipsToBounds = true
        locL.font = .systemFont(ofSize: 9, weight: .bold); locL.textColor = .white
        tagL.font = .boldSystemFont(ofSize: 12); tagL.textColor = .systemCyan
        titleL.font = .boldSystemFont(ofSize: 18); titleL.textColor = .black
        bodyL.font = .systemFont(ofSize: 14); bodyL.numberOfLines = 2; bodyL.textColor = .darkGray
        
        contentView.addSubview(card)
        [shadowContainer, tagL, titleL, bodyL].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; card.addSubview($0) }
        shadowContainer.addSubview(iv); iv.addSubview(play)
        iv.addSubview(locBlur); locBlur.contentView.addSubview(locL)
        
        [iv, play, locBlur, locL, card].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            shadowContainer.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            shadowContainer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            shadowContainer.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            shadowContainer.heightAnchor.constraint(equalToConstant: 200),
            
            iv.topAnchor.constraint(equalTo: shadowContainer.topAnchor),
            iv.leadingAnchor.constraint(equalTo: shadowContainer.leadingAnchor),
            iv.trailingAnchor.constraint(equalTo: shadowContainer.trailingAnchor),
            iv.bottomAnchor.constraint(equalTo: shadowContainer.bottomAnchor),
            
            locBlur.leadingAnchor.constraint(equalTo: iv.leadingAnchor, constant: 10),
            locBlur.bottomAnchor.constraint(equalTo: iv.bottomAnchor, constant: -10),
            locL.centerXAnchor.constraint(equalTo: locBlur.contentView.centerXAnchor),
            locL.centerYAnchor.constraint(equalTo: locBlur.contentView.centerYAnchor),
            locBlur.widthAnchor.constraint(equalTo: locL.widthAnchor, constant: 12),
            locBlur.heightAnchor.constraint(equalTo: locL.heightAnchor, constant: 8),
            
            play.centerXAnchor.constraint(equalTo: iv.centerXAnchor),
            play.centerYAnchor.constraint(equalTo: iv.centerYAnchor),
            play.widthAnchor.constraint(equalToConstant: 50),
            play.heightAnchor.constraint(equalToConstant: 50),
            
            tagL.topAnchor.constraint(equalTo: shadowContainer.bottomAnchor, constant: 12),
            tagL.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
            titleL.topAnchor.constraint(equalTo: tagL.bottomAnchor, constant: 4),
            titleL.leadingAnchor.constraint(equalTo: tagL.leadingAnchor),
            bodyL.topAnchor.constraint(equalTo: titleL.bottomAnchor, constant: 4),
            bodyL.leadingAnchor.constraint(equalTo: tagL.leadingAnchor),
            bodyL.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -15)
        ])
    }
    
    func configure(tag: String, title: String, body: String, imgName: String, isVideo: Bool, loc: String) {
        tagL.text = tag; titleL.text = title; bodyL.text = body; locL.text = loc
        iv.image = UIImage(named: imgName) ?? UIImage(systemName: "photo"); play.isHidden = !isVideo
    }
}
