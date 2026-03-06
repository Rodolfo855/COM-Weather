//
//  COM_WeatherAppController.swift
//  COM Weather
//
//  Created by Victor Rosales on 2/12/26.
//

import UIKit
import SwiftUI

// MARK: - 1. Data Model
struct WeatherEntry: Codable {
    let locationName, temperature, humidity, pressure, timestamp, imageName, detailLocation, description: String
}

// MARK: - 2. SwiftUI Wrapper
struct WeatherViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        return UINavigationController(rootViewController: WeatherViewController())
    }
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

// MARK: - 3. iOS 26 Liquid Glass Component
struct iOS26GlassSpinner: View {
    @Binding var isFinished: Bool
    @State private var rotation: Double = 0
    @State private var isPulsing: Bool = false
    
    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(LinearGradient(colors: [Color.white.opacity(0.4), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)

                if !isFinished {
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            AngularGradient(gradient: Gradient(colors: [.pink, .orange, .pink.opacity(0)]), center: .center),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(rotation))
                        .onAppear {
                            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                                rotation = 360
                            }
                        }
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .symbolEffect(.bounce, value: isFinished)
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                }
            }
            
            Text(isFinished ? "DONE" : "FETCHING LIVE DATA")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .kerning(2.5)
                .foregroundStyle(Color.black.opacity(0.7))
                .opacity(isPulsing && !isFinished ? 0.4 : 0.9)
                .scaleEffect(isPulsing && !isFinished ? 0.96 : 1.0)
                .id("LoadingText" + String(isFinished))
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        isPulsing = true
                    }
                }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isFinished)
    }
}

// MARK: - 4. Skeleton Loading View
class SkeletonCardView: UIView {
    private let shimmerLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSkeleton()
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder); setupSkeleton() }
    
    private func setupSkeleton() {
        backgroundColor = UIColor(white: 0.92, alpha: 1.0)
        layer.cornerRadius = 20
        clipsToBounds = true
        
        shimmerLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.5).cgColor,
            UIColor.clear.cgColor
        ]
        shimmerLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shimmerLayer.endPoint = CGPoint(x: 1, y: 0.5)
        shimmerLayer.locations = [0.3, 0.5, 0.7]
        layer.addSublayer(shimmerLayer)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-0.4, -0.2, 0.0]
        animation.toValue = [1.0, 1.2, 1.4]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        shimmerLayer.add(animation, forKey: "shimmer")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shimmerLayer.frame = bounds
    }
}

// MARK: - 5. UIKit Bridge for Spinner
class ModernSpinnerController: UIView {
    private var isFinished = false { didSet { updateView() } }
    private var hostingController: UIHostingController<iOS26GlassSpinner>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) { super.init(coder: coder); setupView() }

    private func setupView() {
        let spinner = iOS26GlassSpinner(isFinished: .init(get: { self.isFinished }, set: { self.isFinished = $0 }))
        hostingController = UIHostingController(rootView: spinner)
        guard let hc = hostingController else { return }
        hc.view.backgroundColor = .clear
        hc.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hc.view)
        NSLayoutConstraint.activate([
            hc.view.topAnchor.constraint(equalTo: topAnchor),
            hc.view.bottomAnchor.constraint(equalTo: bottomAnchor),
            hc.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hc.view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func showSuccess(completion: @escaping () -> Void) {
        isFinished = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut) {
                self.alpha = 0
                self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            } completion: { _ in
                self.isHidden = true
                completion()
            }
        }
    }
    
    func reset() {
        isFinished = false
        self.alpha = 1
        self.transform = .identity
        self.isHidden = false
    }
    
    private func updateView() {
        hostingController?.rootView = iOS26GlassSpinner(isFinished: .init(get: { self.isFinished }, set: { self.isFinished = $0 }))
    }
}

// MARK: - 6. Main Weather View Controller
class WeatherViewController: UIViewController, UIScrollViewDelegate {
    var weatherEntries: [WeatherEntry] = []
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    let modernSpinner = ModernSpinnerController()
    
    let footerContainer = UIStackView()
    let pullUpLabel = UILabel()
    let lastSyncedLabel = UILabel()
    let pullUpSpinner = UIActivityIndicatorView(style: .medium)
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    var isFetching = false
    var hasTriggeredHaptic = false
    
    let triggerThreshold: CGFloat = 120.0
    let minAnimationTime: Double = 3.5
    let footerHeight: CGFloat = 80.0
    
    let spinnerColor: UIColor = .systemPink
    let hintColor: UIColor = .black
    let activeColor: UIColor = .systemOrange

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Live Weather"
        view.backgroundColor = UIColor(white: 0.87, alpha: 1.0)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        
        setupLayout()
        setupModernSpinner()
        showSkeletons()
        loadRemoteWeatherData(isManual: false)
    }
    
    private func setupModernSpinner() {
        modernSpinner.translatesAutoresizingMaskIntoConstraints = false
        modernSpinner.isHidden = true
        view.addSubview(modernSpinner)
        NSLayoutConstraint.activate([
            modernSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            modernSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            modernSpinner.widthAnchor.constraint(equalToConstant: 250),
            modernSpinner.heightAnchor.constraint(equalToConstant: 250)
        ])
    }

    private func showSkeletons() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for _ in 0...2 {
            let skeleton = SkeletonCardView()
            skeleton.translatesAutoresizingMaskIntoConstraints = false
            skeleton.heightAnchor.constraint(equalToConstant: 260).isActive = true
            stackView.addArrangedSubview(skeleton)
            skeleton.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.9).isActive = true
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
                self.pullUpLabel.textColor = .systemGreen
            } else {
                self.modernSpinner.reset()
            }
        }
        
        let urlString = "https://raw.githubusercontent.com/Rodolfo855/ContentManagementSystem/main/news/weather%2Cjson?v=\(Date().timeIntervalSince1970)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            let elapsed = Date().timeIntervalSince(startTime)
            let remainingDelay = max(0, (self?.minAnimationTime ?? 3.5) - elapsed)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + remainingDelay) {
                if !isManual && data != nil {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    self?.modernSpinner.showSuccess {
                        self?.completeDataProcessing(data: data, error: error)
                    }
                } else {
                    self?.modernSpinner.isHidden = true
                    self?.completeDataProcessing(data: data, error: error)
                }
            }
        }.resume()
    }

    private func completeDataProcessing(data: Data?, error: Error?) {
        UIView.animate(withDuration: 0.5) { self.scrollView.contentInset.bottom = 0 }
        self.isFetching = false
        self.pullUpSpinner.stopAnimating()
        
        self.pullUpLabel.text = "PULL UP FOR FRESH DATA"
        self.pullUpLabel.font = .systemFont(ofSize: 14, weight: .black)
        self.pullUpLabel.textColor = self.hintColor
        
        if let data = data, let decoded = try? JSONDecoder().decode([WeatherEntry].self, from: data) {
            self.weatherEntries = decoded
            self.updateLastSyncedTimestamp()
            self.refreshUI()
        }
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        [scrollView, stackView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        scrollView.clipsToBounds = false

        footerContainer.axis = .vertical; footerContainer.spacing = 2; footerContainer.alignment = .center
        
        pullUpLabel.font = .systemFont(ofSize: 14, weight: .black)
        pullUpLabel.textColor = hintColor
        pullUpLabel.text = "PULL UP FOR FRESH DATA"
        
        lastSyncedLabel.font = .systemFont(ofSize: 12, weight: .bold)
        lastSyncedLabel.textColor = .black
        lastSyncedLabel.text = "Last Synced: --"
        
        pullUpSpinner.hidesWhenStopped = true; pullUpSpinner.color = spinnerColor
        pullUpSpinner.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        footerContainer.addArrangedSubview(pullUpSpinner); footerContainer.addArrangedSubview(pullUpLabel); footerContainer.addArrangedSubview(lastSyncedLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
        ])
        stackView.axis = .vertical; stackView.spacing = 12; stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 5, right: 0)
    }

    private func refreshUI() {
        UIView.transition(with: self.stackView, duration: 0.6, options: .transitionCrossDissolve, animations: {
            self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            for (index, entry) in self.weatherEntries.enumerated() {
                let card = self.createWeatherCard(title: entry.locationName, subtext: "\(entry.temperature) - \(entry.timestamp)", imgName: entry.imageName, locLabel: entry.detailLocation)
                card.tag = index
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleZoomTap(_:)))
                card.addGestureRecognizer(tap)
                card.isUserInteractionEnabled = true
                self.stackView.addArrangedSubview(card)
                card.widthAnchor.constraint(equalTo: self.stackView.widthAnchor, multiplier: 0.9).isActive = true
                self.animateWeatherCardAppearance(for: card, delay: 0.1 * Double(index))
            }
            self.stackView.addArrangedSubview(self.footerContainer)
            self.footerContainer.heightAnchor.constraint(equalToConstant: self.footerHeight).isActive = true
        })
    }

    private func createWeatherCard(title: String, subtext: String, imgName: String, locLabel: String) -> UIView {
        let card = UIView(); card.backgroundColor = .white; card.layer.cornerRadius = 20
        let shadowContainer = UIView()
        shadowContainer.layer.shadowColor = UIColor.black.cgColor; shadowContainer.layer.shadowOpacity = 0.45
        shadowContainer.layer.shadowOffset = CGSize(width: 0, height: 10); shadowContainer.layer.shadowRadius = 8
        shadowContainer.layer.masksToBounds = false
        
        let imageContainer = UIView()
        imageContainer.clipsToBounds = true; imageContainer.layer.cornerRadius = 15
        
        let iv = UIImageView(image: UIImage(named: imgName) ?? UIImage(systemName: "photo"))
        iv.contentMode = .scaleAspectFill; iv.tag = 99
        
        let pinIcon = UIImageView(image: UIImage(systemName: "mappin.and.ellipse"))
        pinIcon.tintColor = .white
        pinIcon.preferredSymbolConfiguration = .init(pointSize: 10, weight: .bold)
        
        let lLabel = UILabel(); lLabel.text = locLabel.uppercased(); lLabel.font = .systemFont(ofSize: 10, weight: .black); lLabel.textColor = .white
        let hStack = UIStackView(arrangedSubviews: [pinIcon, lLabel]); hStack.axis = .horizontal; hStack.spacing = 4; hStack.alignment = .center
        
        let locBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        locBlur.layer.cornerRadius = 8; locBlur.clipsToBounds = true
        
        let tLabel = UILabel(); tLabel.text = title; tLabel.font = .boldSystemFont(ofSize: 22); tLabel.textColor = .black
        let sLabel = UILabel(); sLabel.text = subtext; sLabel.textColor = .systemBlue
        
        [shadowContainer, tLabel, sLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; card.addSubview($0) }
        shadowContainer.addSubview(imageContainer); imageContainer.addSubview(iv); imageContainer.addSubview(locBlur)
        locBlur.contentView.addSubview(hStack)
        
        [imageContainer, iv, locBlur, hStack, pinIcon].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            shadowContainer.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            shadowContainer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            shadowContainer.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            shadowContainer.heightAnchor.constraint(equalToConstant: 180),
            imageContainer.topAnchor.constraint(equalTo: shadowContainer.topAnchor),
            imageContainer.leadingAnchor.constraint(equalTo: shadowContainer.leadingAnchor),
            imageContainer.trailingAnchor.constraint(equalTo: shadowContainer.trailingAnchor),
            imageContainer.bottomAnchor.constraint(equalTo: shadowContainer.bottomAnchor),
            iv.topAnchor.constraint(equalTo: imageContainer.topAnchor, constant: -30),
            iv.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 30),
            iv.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            iv.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            locBlur.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: -12),
            locBlur.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor, constant: 12),
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pullDistance = (scrollView.contentOffset.y + scrollView.frame.size.height) - scrollView.contentSize.height
        if pullDistance > triggerThreshold && !isFetching {
            if !hasTriggeredHaptic {
                pullUpLabel.text = "RELEASE TO REFRESH"; pullUpLabel.textColor = activeColor
                feedbackGenerator.impactOccurred(); hasTriggeredHaptic = true
                UIView.animate(withDuration: 0.2) { self.pullUpLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1) }
            }
        } else if !isFetching {
            pullUpLabel.text = "PULL UP FOR FRESH DATA"
            pullUpLabel.textColor = hintColor; pullUpLabel.font = .systemFont(ofSize: 14, weight: .black)
            pullUpLabel.transform = .identity; hasTriggeredHaptic = false
        }
        
        guard let windowScene = view.window?.windowScene else { return }
        let screenHeight = windowScene.screen.bounds.height

        for view in stackView.arrangedSubviews {
            guard let shadowContainer = view.subviews.first(where: { $0.layer.shadowColor != nil }),
                  let imageContainer = shadowContainer.subviews.first,
                  let imageView = imageContainer.subviews.first(where: { $0.tag == 99 }) as? UIImageView else { continue }
            
            let frameInWindow = view.convert(view.bounds, to: nil)
            let distanceFromCenter = frameInWindow.midY - (screenHeight / 2)
            imageView.transform = CGAffineTransform(translationX: 0, y: -(distanceFromCenter / 12))
        }
    }
    
    func animateWeatherCardAppearance(for card: UIView, delay: TimeInterval) {
        card.alpha = 0
      
        card.transform = CGAffineTransform(translationX: 0, y: 60).scaledBy(x: 0.85, y: 0.85)  // Larger movement and smaller starting size
        
        UIView.animate(withDuration: 1.0, delay: delay, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut) {
            card.alpha = 1  // Fade-in
            card.transform = .identity  // Slide up to original position and scale to normal size
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let pullDistance = (scrollView.contentOffset.y + scrollView.frame.size.height) - scrollView.contentSize.height
        if pullDistance > triggerThreshold && !isFetching {
            UIView.animate(withDuration: 0.3) { scrollView.contentInset.bottom = self.footerHeight }
            loadRemoteWeatherData(isManual: true)
        }
    }

    private func updateLastSyncedTimestamp() {
        let formatter = DateFormatter(); formatter.dateFormat = "MMM d, h:mm:ss a"
        lastSyncedLabel.text = "Last Synced: \(formatter.string(from: Date()))"
    }

    @objc func handleZoomTap(_ gesture: UITapGestureRecognizer) {}
    @objc func dismissVC() { dismiss(animated: true) }
}
