//
//  COM_WeatherAppController.swift
//  COM Weather
//
//  Created by Victor Rosales  on 2/12/26.
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

class WeatherViewController: UIViewController, UIScrollViewDelegate {
    var weatherEntries: [WeatherEntry] = []
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    let footerContainer = UIStackView()
    let pullUpLabel = UILabel()
    let lastSyncedLabel = UILabel()
    let pullUpSpinner = UIActivityIndicatorView(style: .medium)
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    var isFetching = false
    var hasTriggeredHaptic = false
    
    let triggerThreshold: CGFloat = 120.0
    let minAnimationTime: Double = 3.0
    let fetchTimeout: Double = 5.0
    let spinnerColor: UIColor = .systemPink
    let hintColor: UIColor = .black
    let activeColor: UIColor = .systemOrange
    let successColor: UIColor = .systemGreen
    
    let footerHeight: CGFloat = 80.0
    let stackSpacing: CGFloat = 12.0
    let bottomContentInset: CGFloat = 5.0

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Live Weather"
        view.backgroundColor = UIColor(white: 0.87, alpha: 1.0)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        scrollView.clipsToBounds = false
        
        setupLayout()
        setupActivityIndicator()
        loadRemoteWeatherData(isManual: false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        let pullDistance = (offset + frameHeight) - contentHeight
        
        if pullDistance > triggerThreshold {
            if !hasTriggeredHaptic && !isFetching {
                pullUpLabel.text = "RELEASE TO REFRESH"
                pullUpLabel.textColor = activeColor
                feedbackGenerator.impactOccurred()
                hasTriggeredHaptic = true
                UIView.animate(withDuration: 0.2) {
                    self.pullUpLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }
            }
        } else if !isFetching {
            pullUpLabel.text = "PULL UP FOR FRESH DATA"
            pullUpLabel.font = .systemFont(ofSize: 15, weight: .black)
            pullUpLabel.textColor = hintColor
            pullUpLabel.transform = .identity
            hasTriggeredHaptic = false
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        let pullDistance = (offset + frameHeight) - contentHeight
        
        if pullDistance > triggerThreshold && !isFetching {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                scrollView.contentInset.bottom = self.footerHeight
            }
            loadRemoteWeatherData(isManual: true)
        }
    }
    
    func loadRemoteWeatherData(isManual: Bool = false) {
        guard !isFetching else { return }
        isFetching = true
        
        let startTime = Date()
        
        DispatchQueue.main.async {
            if isManual {
                self.pullUpSpinner.startAnimating()
                self.pullUpLabel.text = "FETCHING..."
                self.pullUpLabel.textColor = self.successColor
            } else {
                self.activityIndicator.startAnimating()
            }
        }
        
        let urlString = "https://raw.githubusercontent.com/Rodolfo855/ContentManagementSystem/main/news/weather%2Cjson?v=\(Date().timeIntervalSince1970)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        request.timeoutInterval = fetchTimeout
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            let elapsed = Date().timeIntervalSince(startTime)
            let requiredDelay = isManual ? (self?.minAnimationTime ?? 3.0) : 0.0
            let remainingDelay = max(0, requiredDelay - elapsed)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + remainingDelay) {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
                    self?.scrollView.contentInset.bottom = 0
                }

                self?.isFetching = false
                self?.pullUpSpinner.stopAnimating()
                self?.activityIndicator.stopAnimating()
                self?.pullUpLabel.text = "PULL UP FOR FRESH DATA"
                self?.pullUpLabel.textColor = self?.hintColor
                
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode([WeatherEntry].self, from: data)
                        self?.weatherEntries = decodedData
                        self?.updateLastSyncedTimestamp()
                        self?.refreshUI()
                    } catch {
                        self?.showErrorAlert(message: "Data format error.")
                    }
                } else if error != nil {
                    self?.showErrorAlert(message: "Connection failed.")
                }
            }
        }.resume()
    }

    private func updateLastSyncedTimestamp() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm:ss a"
        lastSyncedLabel.text = "Last Synced: \(formatter.string(from: Date()))"
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Fetch Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
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
        
        stackView.addArrangedSubview(footerContainer)
        NSLayoutConstraint.activate([
            footerContainer.heightAnchor.constraint(equalToConstant: footerHeight)
        ])
    }
    
    @objc func handleZoomTap(_ gesture: UITapGestureRecognizer) {
        guard let tag = gesture.view?.tag else { return }
        let data = weatherEntries[tag]
        let zoomVC = ZoomAnimationViewController()
        zoomVC.headline = data.locationName
        zoomVC.subheadline = data.temperature
        zoomVC.imageName = data.imageName
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
        
        footerContainer.axis = .vertical
        footerContainer.spacing = 2
        footerContainer.alignment = .center
        
        pullUpLabel.font = .systemFont(ofSize: 15, weight: .black)
        pullUpLabel.textColor = hintColor
        pullUpLabel.text = "PULL UP FOR FRESH DATA"
        
        lastSyncedLabel.font = .systemFont(ofSize: 12, weight: .bold)
        lastSyncedLabel.textColor = .systemGray
        lastSyncedLabel.text = "Last Synced: --"
        
        pullUpSpinner.hidesWhenStopped = true
        pullUpSpinner.color = spinnerColor
        pullUpSpinner.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        footerContainer.addArrangedSubview(pullUpSpinner)
        footerContainer.addArrangedSubview(pullUpLabel)
        footerContainer.addArrangedSubview(lastSyncedLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        stackView.axis = .vertical
        stackView.spacing = stackSpacing
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: bottomContentInset, right: 0)
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
        let lLabel = UILabel(); lLabel.text = locLabel.uppercased(); lLabel.font = .systemFont(ofSize: 10, weight: .black); lLabel.textColor = .white
        let hStack = UIStackView(arrangedSubviews: [pinIcon, lLabel]); hStack.axis = .horizontal; hStack.spacing = 4; hStack.alignment = .center
        let locBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark)); locBlur.layer.cornerRadius = 8; locBlur.clipsToBounds = true
        let tLabel = UILabel(); tLabel.text = title; tLabel.font = .boldSystemFont(ofSize: 22); tLabel.textColor = .black
        let sLabel = UILabel(); sLabel.text = subtext; sLabel.textColor = .systemBlue
        [shadowContainer, tLabel, sLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; card.addSubview($0) }
        shadowContainer.addSubview(iv); iv.addSubview(locBlur); locBlur.contentView.addSubview(hStack)
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
