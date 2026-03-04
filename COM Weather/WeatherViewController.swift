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

struct WeatherEntry: Codable {
    let locationName: String
    let temperature: String
    let humidity: String
    let pressure: String
    let timestamp: String
    let imageName: String
    let detailLocation: String
    let description: String
}

class WeatherViewController: UIViewController {
    var weatherEntries: [WeatherEntry] = []
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Live Weather"
        view.backgroundColor = UIColor(white: 0.87, alpha: 1.0)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        setupLayout()
        setupActivityIndicator()
        loadRemoteWeatherData()
    }
    
    func loadRemoteWeatherData() {
        activityIndicator.startAnimating()
        let urlString = "https://raw.githubusercontent.com/Rodolfo855/ContentManagementSystem/main/news/weather%2Cjson"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 10.0
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
            }
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode([WeatherEntry].self, from: data)
                    DispatchQueue.main.async {
                        self?.weatherEntries = decodedData
                        self?.refreshUI()
                    }
                } catch {
                    print("JSON Decoding Error: \(error)")
                }
            }
        }.resume()
    }

    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .systemBlue
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func refreshUI() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, entry) in weatherEntries.enumerated() {
            let card = createWeatherCard(
                title: entry.locationName,
                subtext: "\(entry.temperature) - \(entry.timestamp)",
                imgName: entry.imageName,
                locLabel: entry.detailLocation
            )
            
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
        let data = weatherEntries[tag]
        
        let zoomVC = ZoomAnimationViewController()
        zoomVC.headline = data.locationName
        zoomVC.subheadline = data.temperature
        zoomVC.imageName = data.imageName
        
        // Passing the new dynamic fields to the detail view
        zoomVC.humidity = data.humidity
        zoomVC.pressure = data.pressure
        zoomVC.detailedDescription = data.description
        
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

        let tLabel = UILabel(); tLabel.text = title; tLabel.font = .boldSystemFont(ofSize: 22)
        tLabel.textColor = .black
        let sLabel = UILabel(); sLabel.text = subtext; sLabel.textColor = .systemBlue

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
            
            locBlur.bottomAnchor.constraint(equalTo: iv.bottomAnchor, constant: -12),
            locBlur.leadingAnchor.constraint(equalTo: iv.leadingAnchor, constant: 12),
            
            pinIcon.widthAnchor.constraint(equalToConstant: 12),
            pinIcon.heightAnchor.constraint(equalToConstant: 12),
            
            hStack.centerXAnchor.constraint(equalTo: locBlur.contentView.centerXAnchor),
            hStack.centerYAnchor.constraint(equalTo: locBlur.contentView.centerYAnchor),
            
            locBlur.widthAnchor.constraint(equalTo: hStack.widthAnchor, constant: 16),
            locBlur.heightAnchor.constraint(equalTo: hStack.heightAnchor, constant: 10),
            
            tLabel.topAnchor.constraint(equalTo: shadowContainer.bottomAnchor, constant: 12),
            tLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
            sLabel.topAnchor.constraint(equalTo: tLabel.bottomAnchor, constant: 4),
            sLabel.leadingAnchor.constraint(equalTo: tLabel.leadingAnchor),
            sLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])
        
        return card
    }
}
