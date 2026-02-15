//
//  ZoomAnimation.swift
//  COM Weather
//
//  Created by Victor Rosales  on 2/15/26.
//
    
import UIKit

class ZoomAnimationViewController: UIViewController {
    // Data passed from the clicked card
    var headline: String?
    var subheadline: String?
    var imageName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
    }
    
    private func setupLayout() {
        let iv = UIImageView(image: UIImage(named: imageName ?? "") ?? UIImage(systemName: "photo"))
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 25
        
        let titleLabel = UILabel()
        titleLabel.text = headline
        
        // --- FIXED ROUNDED FONT LOGIC ---
        let baseFont = UIFont.systemFont(ofSize: 30, weight: .black)
        if let roundedDescriptor = baseFont.fontDescriptor.withDesign(.rounded) {
            titleLabel.font = UIFont(descriptor: roundedDescriptor, size: 30)
        } else {
            titleLabel.font = baseFont
        }
        
        let statusLabel = UILabel()
        statusLabel.text = subheadline
        statusLabel.textColor = .systemBlue
        // FIXED: Using preferredFont for title2
        statusLabel.font = .preferredFont(forTextStyle: .title2)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = """
        This is a detailed view for \(headline ?? "this location"). 
        
        Developer: Victor Rosales
        """
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .darkGray
        descriptionLabel.font = .systemFont(ofSize: 16)
        
        [iv, titleLabel, statusLabel, descriptionLabel].forEach {
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
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25)
        ])
    }
}
