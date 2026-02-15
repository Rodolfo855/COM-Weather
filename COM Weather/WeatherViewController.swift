//
//  WeatherViewController.swift
//  COM Weather
//
//  Created by Victor Rosales  on 2/14/26.
//

import UIKit
import SwiftUI

struct WeatherViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        return UINavigationController(rootViewController: WeatherViewController())
    }
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

class WeatherViewController: UIViewController {
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Live Weather"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        view.backgroundColor = UIColor(white: 0.94, alpha: 1.0)
        setupLayout()
        
        let weatherData = [
            ("Kentfield Campus", "68°F - Sunny", "banner1", "Main Quad"),
            ("Indian Valley", "64°F - Breeze", "sunny", "Organic Farm"),
            ("Science Village", "67°F - Optimal", "image3", "Lab Wing"),
            ("Student Center", "70°F - Clear", "image4", "Bookstore"),
            ("Performing Arts", "66°F - Cool", "image5", "Theater"),
            ("Wellness Center", "69°F - Calm", "sunny", "Gymnasium")
        ]
        
        for item in weatherData {
            let card = createWeatherCard(title: item.0, subtext: item.1, imgName: item.2, locLabel: item.3)
            stackView.addArrangedSubview(card)
            card.translatesAutoresizingMaskIntoConstraints = false
            card.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.9).isActive = true
        }
    }
    
    @objc func dismissVC() { dismiss(animated: true) }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical; stackView.spacing = 25; stackView.alignment = .center
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -60),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    private func createWeatherCard(title: String, subtext: String, imgName: String, locLabel: String) -> UIView {
        let card = UIView(); card.backgroundColor = .white; card.layer.cornerRadius = 20
        
        // --- BOLDER SHADOW LOGIC ---
        let shadowContainer = UIView()
        shadowContainer.backgroundColor = .clear
        shadowContainer.layer.shadowColor = UIColor.black.cgColor
        shadowContainer.layer.shadowOpacity = 0.45 // Bolder
        shadowContainer.layer.shadowOffset = CGSize(width: 0, height: 10)
        shadowContainer.layer.shadowRadius = 15 // Softer, deeper spread
        shadowContainer.layer.masksToBounds = false
        
        let iv = UIImageView(image: UIImage(named: imgName) ?? UIImage(systemName: "photo"))
        iv.contentMode = .scaleAspectFill; iv.clipsToBounds = true; iv.layer.cornerRadius = 15
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        blur.layer.cornerRadius = 8; blur.clipsToBounds = true
        let lTag = UILabel(); lTag.text = locLabel; lTag.font = .systemFont(ofSize: 10, weight: .black); lTag.textColor = .white
        
        let tLabel = UILabel(); tLabel.text = title; tLabel.font = .boldSystemFont(ofSize: 22)
        let sLabel = UILabel(); sLabel.text = subtext; sLabel.textColor = .systemBlue
        let syncLabel = UILabel(); syncLabel.text = "Synced: \(Date().formatted(date: .omitted, time: .shortened))"; syncLabel.font = .systemFont(ofSize: 12); syncLabel.textColor = .lightGray
        
        [shadowContainer, tLabel, sLabel, syncLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; card.addSubview($0) }
        shadowContainer.addSubview(iv)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.addSubview(blur); blur.contentView.addSubview(lTag)
        blur.translatesAutoresizingMaskIntoConstraints = false; lTag.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            shadowContainer.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            shadowContainer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            shadowContainer.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            shadowContainer.heightAnchor.constraint(equalToConstant: 180),
            iv.topAnchor.constraint(equalTo: shadowContainer.topAnchor),
            iv.leadingAnchor.constraint(equalTo: shadowContainer.leadingAnchor),
            iv.trailingAnchor.constraint(equalTo: shadowContainer.trailingAnchor),
            iv.bottomAnchor.constraint(equalTo: shadowContainer.bottomAnchor),
            blur.leadingAnchor.constraint(equalTo: iv.leadingAnchor, constant: 10),
            blur.bottomAnchor.constraint(equalTo: iv.bottomAnchor, constant: -10),
            lTag.centerXAnchor.constraint(equalTo: blur.contentView.centerXAnchor),
            lTag.centerYAnchor.constraint(equalTo: blur.contentView.centerYAnchor),
            blur.widthAnchor.constraint(equalTo: lTag.widthAnchor, constant: 16),
            blur.heightAnchor.constraint(equalTo: lTag.heightAnchor, constant: 10),
            tLabel.topAnchor.constraint(equalTo: shadowContainer.bottomAnchor, constant: 12),
            tLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
            sLabel.topAnchor.constraint(equalTo: tLabel.bottomAnchor, constant: 4),
            sLabel.leadingAnchor.constraint(equalTo: tLabel.leadingAnchor),
            syncLabel.topAnchor.constraint(equalTo: sLabel.bottomAnchor, constant: 8),
            syncLabel.leadingAnchor.constraint(equalTo: tLabel.leadingAnchor),
            syncLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])
        return card
    }
}
