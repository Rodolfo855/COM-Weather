//
//  ZoomAnimation.swift
//  COM Weather
//
//  Created by Victor Rosales on 2/15/26.
//

import UIKit

class ZoomAnimationViewController: UIViewController {
    // MARK: - Data Properties
    var headline: String?
    var subheadline: String?
    var imageName: String?
    var humidity: String?
    var pressure: String?
    var detailedDescription: String?
    
    // Fix: Added missing property for the WeatherViewController to access
    var statusLabelFont: UIFont?

    // UI Components
    private let iv = UIImageView()
    private let titleLabel = UILabel()
    private let statusLabel = UILabel()
    private let statsLabel = UILabel()
    private let descriptionLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        updateUI() // Load data into labels
    }
    
    // Fix: Added missing updateUI method
    func updateUI() {
        loadViewIfNeeded()
        iv.image = UIImage(named: imageName ?? "") ?? UIImage(systemName: "photo")
        titleLabel.text = headline
        statusLabel.text = subheadline
        
        // Handle stats display only if data exists (Weather vs Newsletter)
        if let h = humidity, let p = pressure {
            statsLabel.text = "Humidity: \(h) | Pressure: \(p)"
            statsLabel.isHidden = false
        } else {
            statsLabel.isHidden = true
        }
        
        descriptionLabel.text = detailedDescription
        
        // Fix: Properly apply the font if it was passed, otherwise use default
        if let customFont = statusLabelFont {
            statusLabel.font = customFont
        }
    }
    
    private func setupLayout() {
        // Fix: Corrected Rounded Font Syntax for Title
        let titleBase = UIFont.systemFont(ofSize: 30, weight: .black)
        if let roundedTitle = titleBase.fontDescriptor.withDesign(.rounded) {
            titleLabel.font = UIFont(descriptor: roundedTitle, size: 30)
        } else {
            titleLabel.font = titleBase
        }
        
        // Fix: Corrected Rounded Font Syntax for Status
        let statusBase = UIFont.preferredFont(forTextStyle: .title2)
        if let roundedStatus = statusBase.fontDescriptor.withDesign(.rounded) {
            statusLabel.font = UIFont(descriptor: roundedStatus, size: statusBase.pointSize)
        } else {
            statusLabel.font = statusBase
        }

        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 30
        
        statusLabel.textColor = .systemBlue
        statsLabel.font = .systemFont(ofSize: 14, weight: .medium)
        statsLabel.textColor = .black
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .darkGray
        descriptionLabel.font = .systemFont(ofSize: 16)
        
        [iv, titleLabel, statusLabel, statsLabel, descriptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            iv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            iv.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            iv.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            iv.heightAnchor.constraint(equalToConstant: 320),
            
            titleLabel.topAnchor.constraint(equalTo: iv.bottomAnchor, constant: 25),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            statsLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            statsLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: statsLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25)
        ])
    }
}
