//
//  WeatherViewController.swift
//  COM Weather
//
//  Created by Victor Rosales on 2/14/26.
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
    
    let weatherData = [
        ("Kentfield Campus", "68°F - Sunny", "banner1", "New Building"),
        ("Indian Valley", "64°F - Breeze", "sunny", "Organic Farm"),
        ("Science Village", "67°F - Optimal", "image3", "Lab"),
        ("Student Center", "70°F - Clear", "image4", "Bookstore"),
        ("Performing Arts", "66°F - Cool", "image5", "Theater"),
        ("Wellness Center", "69°F - Calm", "sunny", "Gymnasium")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Live Weather"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        view.backgroundColor = UIColor(white: 0.87, alpha: 1.0)
        setupLayout()
        
        for (index, item) in weatherData.enumerated() {
            let card = createWeatherCard(title: item.0, subtext: item.1, imgName: item.2, locLabel: item.3)
            
            // --- ZOOM INTEGRATION ---
            card.tag = index
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleZoomTap(_:)))
            card.addGestureRecognizer(tap)
            card.isUserInteractionEnabled = true
            
            stackView.addArrangedSubview(card)
            card.translatesAutoresizingMaskIntoConstraints = false
            card.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.9).isActive = true
        }
    }
    
    @objc func handleZoomTap(_ gesture: UITapGestureRecognizer) {
        guard let tag = gesture.view?.tag else { return }
        let data = weatherData[tag]
        
        let zoomVC = ZoomAnimationViewController()
        zoomVC.headline = data.0
        zoomVC.subheadline = data.1
        zoomVC.imageName = data.2
        
        if let sheet = zoomVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(zoomVC, animated: true)
    }
    
    @objc func dismissVC() { dismiss(animated: true) }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        [scrollView, stackView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        stackView.axis = .vertical
        stackView.spacing = 25
        stackView.alignment = .center
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -30),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        view.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private func createWeatherCard(title: String, subtext: String, imgName: String, locLabel: String) -> UIView {
        let card = UIView(); card.backgroundColor = .white; card.layer.cornerRadius = 20
        
        let shadowContainer = UIView()
        shadowContainer.layer.shadowColor = UIColor.black.cgColor
        shadowContainer.layer.shadowOpacity = 0.45
        shadowContainer.layer.shadowOffset = CGSize(width: 0, height: 10)
        shadowContainer.layer.shadowRadius = 8
        shadowContainer.layer.masksToBounds = false
        
        let iv = UIImageView(image: UIImage(named: imgName) ?? UIImage(systemName: "photo"))
        iv.contentMode = .scaleAspectFill; iv.clipsToBounds = true; iv.layer.cornerRadius = 15
        
        // --- PRO OVERLAY: PIN ICON + TEXT ---
        let pinIcon = UIImageView(image: UIImage(systemName: "mappin.and.ellipse"))
        pinIcon.tintColor = .white
        pinIcon.preferredSymbolConfiguration = .init(pointSize: 10, weight: .bold)
        
        let lLabel = UILabel()
        lLabel.text = locLabel.uppercased()
        lLabel.font = .systemFont(ofSize: 10, weight: .black)
        lLabel.textColor = .white
        
        let hStack = UIStackView(arrangedSubviews: [pinIcon, lLabel])
        hStack.axis = .horizontal; hStack.spacing = 4; hStack.alignment = .center
        
        let locBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        locBlur.layer.cornerRadius = 8; locBlur.clipsToBounds = true
        // ------------------------------------

        let tLabel = UILabel(); tLabel.text = title; tLabel.font = .boldSystemFont(ofSize: 22)
        tLabel.textColor = .black
        let sLabel = UILabel(); sLabel.text = subtext; sLabel.textColor = .systemBlue
        
        // ADD HIERARCHY
        [shadowContainer, tLabel, sLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview($0)
        }
        shadowContainer.addSubview(iv)
        iv.addSubview(locBlur)
        locBlur.contentView.addSubview(hStack)
        
        [iv, locBlur, hStack, pinIcon].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            shadowContainer.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            shadowContainer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            shadowContainer.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            shadowContainer.heightAnchor.constraint(equalToConstant: 180),
            
            iv.topAnchor.constraint(equalTo: shadowContainer.topAnchor),
            iv.leadingAnchor.constraint(equalTo: shadowContainer.leadingAnchor),
            iv.trailingAnchor.constraint(equalTo: shadowContainer.trailingAnchor),
            iv.bottomAnchor.constraint(equalTo: shadowContainer.bottomAnchor),
            
            // --- FIXED: BOTTOM LEFT ALIGNED OVERLAY ---
            // Pin the bottom of the blur to the bottom of the image (with 12pt padding)
            locBlur.bottomAnchor.constraint(equalTo: iv.bottomAnchor, constant: -12),
            locBlur.leadingAnchor.constraint(equalTo: iv.leadingAnchor, constant: 12),
            
            pinIcon.widthAnchor.constraint(equalToConstant: 12),
            pinIcon.heightAnchor.constraint(equalToConstant: 12),
            
            hStack.centerXAnchor.constraint(equalTo: locBlur.contentView.centerXAnchor),
            hStack.centerYAnchor.constraint(equalTo: locBlur.contentView.centerYAnchor),
            
            locBlur.widthAnchor.constraint(equalTo: hStack.widthAnchor, constant: 16),
            locBlur.heightAnchor.constraint(equalTo: hStack.heightAnchor, constant: 10),
            // ------------------------------------------
            
            tLabel.topAnchor.constraint(equalTo: shadowContainer.bottomAnchor, constant: 12),
            tLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
            sLabel.topAnchor.constraint(equalTo: tLabel.bottomAnchor, constant: 4),
            sLabel.leadingAnchor.constraint(equalTo: tLabel.leadingAnchor),
            sLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])
        
        return card
    }
}
