//
//  COM_WeatherAppController.swift
//  COM Weather
//
//  Created by Victor Rosales on 2/12/26.
//

import UIKit
import SwiftUI
import Lottie

struct WeatherEntry: Codable {
    let locationName, temperature, humidity, pressure, timestamp, imageName, detailLocation, description: String?
    var imageURL: URL? {
        guard let name = imageName else { return nil }
        return URL(string: name)
    }
}

struct WeatherViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        return UINavigationController(rootViewController: WeatherViewController())
    }
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
}

struct iOS26GlassSpinner: View {
    @Binding var isFinished: Bool
    @Binding var isError: Bool
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

                if !isFinished && !isError {
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
                } else if isError {
                    LottieErrorAnimationView()
                        .frame(width: 80, height: 80)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .symbolEffect(.bounce, value: isFinished)
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                }
            }
            
            Text(isError ? "CONNECTION FAILED" : (isFinished ? "DONE" : "FETCHING LIVE DATA"))
                .font(.system(size: 13, weight: .black, design: .rounded))
                .kerning(2.5)
                .foregroundStyle(isError ? Color.red.opacity(0.8) : Color.primary.opacity(0.7))
                .id("StatusText" + String(isFinished) + String(isError))
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        isPulsing = true
                    }
                }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isFinished)
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isError)
    }
}

class SkeletonCardView: UIView {
    private let shimmerLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSkeleton()
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder); setupSkeleton() }
    
    private func setupSkeleton() {
        backgroundColor = UIColor.secondarySystemBackground
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

class ModernSpinnerController: UIView {
    var isFinished = false { didSet { updateView() } }
    var isError = false { didSet { updateView() } }
    private var hostingController: UIHostingController<iOS26GlassSpinner>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) { super.init(coder: coder); setupView() }

    private func setupView() {
        updateView()
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            UIView.animate(withDuration: 0.6, animations: {
                self.alpha = 0
                self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }) { _ in
                self.isHidden = true
                completion()
            }
        }
    }

    func showError(completion: @escaping () -> Void) {
        isError = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            UIView.animate(withDuration: 0.6, animations: {
                self.alpha = 0
            }) { _ in
                self.isHidden = true
                completion()
            }
        }
    }
    
    func reset() {
        isFinished = false
        isError = false
        self.alpha = 1
        self.transform = .identity
        self.isHidden = false
        updateView()
    }
    
    private func updateView() {
        let spinner = iOS26GlassSpinner(
            isFinished: .init(get: { self.isFinished }, set: { self.isFinished = $0 }),
            isError: .init(get: { self.isError }, set: { self.isError = $0 })
        )
        if hostingController == nil {
            hostingController = UIHostingController(rootView: spinner)
        } else {
            hostingController?.rootView = spinner
        }
    }
}

class WeatherViewController: UIViewController, UIScrollViewDelegate {
    static let themeBackGroundColor = UIColor.systemBackground
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
    var isShowingUpToDate = false
    var errorCardIndexes = Set<Int>()
    
    let triggerThreshold: CGFloat = 120.0
    let initialAnimationTime: UInt64 = 1_500_000_000
    let manualAnimationTime: UInt64 = 1_500_000_000
    let footerHeight: CGFloat = 80.0
    
    let spinnerColor: UIColor = .systemPink
    let hintColor: UIColor = .label
    let activeColor: UIColor = .systemOrange
    
    var lastCacheClearTime: Date?
    var cacheCoolDown: TimeInterval = 300
    private var fetchTask: Task<Void, Never>?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Live Weather"
        view.backgroundColor = Self.themeBackGroundColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        
        setupLayout()
        setupModernSpinner()
        showSkeletons()
        loadRemoteWeatherData(isManual: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchTask?.cancel()
    }
    
    private func setupModernSpinner() {
        modernSpinner.translatesAutoresizingMaskIntoConstraints = false
        modernSpinner.isHidden = false
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
        
        if isManual {
            self.pullUpSpinner.startAnimating()
            self.pullUpLabel.text = "FETCHING..."
            self.pullUpLabel.textColor = .systemGreen
        } else {
            self.modernSpinner.reset()
        }

        fetchTask = Task {
            let urlString = "https://raw.githubusercontent.com/Rodolfo855/ContentManagementSystem/main/news/weather%2Cjson?v=\(Date().timeIntervalSince1970)"
            guard let url = URL(string: urlString) else { return }

            do {
                try await Task.sleep(nanoseconds: isManual ? manualAnimationTime : initialAnimationTime)
                
                let (data, _) = try await URLSession.shared.data(from: url)
                
                if let decoded = try? JSONDecoder().decode([WeatherEntry].self, from: data) {
                    await MainActor.run {
                        self.errorCardIndexes.removeAll()
                        if !isManual {
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            self.modernSpinner.showSuccess {
                                self.completeDataProcessing(data: data, decoded: decoded)
                            }
                        } else {
                            self.completeDataProcessing(data: data, decoded: decoded)
                        }
                    }
                } else {
                    throw NSError(domain: "DataError", code: 0)
                }
            } catch {
                await MainActor.run {
                    if !isManual {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                        self.modernSpinner.showError {
                            self.dismiss(animated: true)
                        }
                    } else {
                        self.handleManualRefreshFailure()
                    }
                }
            }
        }
    }

    private func handleManualRefreshFailure() {
        self.isFetching = false
        self.pullUpSpinner.stopAnimating()
        self.pullUpLabel.text = "CONNECTION FAILED"
        self.pullUpLabel.textColor = .systemRed
        UIView.animate(withDuration: 0.3) { self.scrollView.contentInset.bottom = 0 }
        self.replaceCardImagesWithErrorAnimation()
    }

    private func replaceCardImagesWithErrorAnimation() {
        for card in stackView.arrangedSubviews {
            guard let imageView = card.viewWithTag(99) as? UIImageView else { continue }
            let index = card.tag
            errorCardIndexes.insert(index)
            imageView.image = nil
            imageView.subviews.forEach { $0.removeFromSuperview() }
            
            let errorHost = UIHostingController(rootView: LottieErrorAnimationView())
            errorHost.view.backgroundColor = .clear
            errorHost.view.translatesAutoresizingMaskIntoConstraints = false
            imageView.addSubview(errorHost.view)
            
            NSLayoutConstraint.activate([
                errorHost.view.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                errorHost.view.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
                errorHost.view.widthAnchor.constraint(equalToConstant: 90),
                errorHost.view.heightAnchor.constraint(equalToConstant: 90)
            ])
        }
    }

    private func completeDataProcessing(data: Data?, decoded: [WeatherEntry]?) {
        UIView.animate(withDuration: 0.5) { self.scrollView.contentInset.bottom = 0 }
        self.isFetching = false
        self.pullUpSpinner.stopAnimating()
        self.isShowingUpToDate = true
        self.hasTriggeredHaptic = false
        self.pullUpLabel.text = "UP TO DATE!"
        self.pullUpLabel.textColor = .systemCyan
        
        if let decoded = decoded {
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
        
        footerContainer.axis = .vertical
        footerContainer.spacing = 2
        footerContainer.alignment = .center
        
        pullUpLabel.font = .systemFont(ofSize: 14, weight: .black)
        pullUpLabel.text = "PULL UP FOR FRESH DATA"
        pullUpLabel.textColor = .label
        
        lastSyncedLabel.font = .systemFont(ofSize: 12, weight: .bold)
        lastSyncedLabel.text = "Last Synced: --"
        lastSyncedLabel.textColor = .secondaryLabel
        
        pullUpSpinner.hidesWhenStopped = true
        pullUpSpinner.color = spinnerColor
        
        footerContainer.addArrangedSubview(pullUpSpinner)
        footerContainer.addArrangedSubview(pullUpLabel)
        footerContainer.addArrangedSubview(lastSyncedLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 5, right: 0)
    }

    private func refreshUI() {
        UIView.transition(with: self.stackView, duration: 0.6, options: .transitionCrossDissolve, animations: {
            self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            for (index, entry) in self.weatherEntries.enumerated() {
                let card = self.createWeatherCard(entry: entry)
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

    private func createWeatherCard(entry: WeatherEntry) -> UIView {
        let card = UIView(); card.backgroundColor = .secondarySystemBackground; card.layer.cornerRadius = 20
        let shadowContainer = UIView(); shadowContainer.layer.shadowOpacity = 0.18; shadowContainer.layer.shadowRadius = 8; shadowContainer.layer.shadowColor = UIColor.black.cgColor; shadowContainer.layer.shadowOffset = CGSize(width: 0, height: 4); shadowContainer.layer.masksToBounds = false
        let imageContainer = UIView(); imageContainer.clipsToBounds = true; imageContainer.layer.cornerRadius = 15
        let iv = UIImageView(); iv.contentMode = .scaleAspectFill; iv.tag = 99
        
        if let url = URL(string: entry.imageName ?? ""), url.scheme == "https" {
            iv.loadRemoteImage(from: url)
        } else {
            iv.image = UIImage(named: entry.imageName ?? "") ?? UIImage(systemName: "photo")
        }
        
        let tLabel = UILabel(); tLabel.text = entry.locationName; tLabel.font = .boldSystemFont(ofSize: 22); tLabel.textColor = .label
        let sLabel = UILabel(); sLabel.text = "\(entry.temperature ?? "") - \(entry.timestamp ?? "")"; sLabel.textColor = .systemBlue
        
        [shadowContainer, tLabel, sLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; card.addSubview($0) }
        shadowContainer.addSubview(imageContainer); imageContainer.addSubview(iv)
        [imageContainer, iv].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            shadowContainer.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            shadowContainer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            shadowContainer.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            shadowContainer.heightAnchor.constraint(equalToConstant: 180),
            imageContainer.topAnchor.constraint(equalTo: shadowContainer.topAnchor),
            imageContainer.bottomAnchor.constraint(equalTo: shadowContainer.bottomAnchor),
            imageContainer.leadingAnchor.constraint(equalTo: shadowContainer.leadingAnchor),
            imageContainer.trailingAnchor.constraint(equalTo: shadowContainer.trailingAnchor),
            iv.topAnchor.constraint(equalTo: imageContainer.topAnchor, constant: -30),
            iv.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 30),
            iv.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            iv.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
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
        
        if isFetching { return }
        
        if pullDistance > triggerThreshold {
            if !hasTriggeredHaptic {
                pullUpLabel.text = "RELEASE TO REFRESH"
                pullUpLabel.textColor = activeColor
                feedbackGenerator.impactOccurred()
                hasTriggeredHaptic = true
            }
        } else {
            if isShowingUpToDate {
                pullUpLabel.text = "UP TO DATE!"
                pullUpLabel.textColor = .systemCyan
                
                if abs(scrollView.contentOffset.y) > 8 || pullDistance < 20 {
                    isShowingUpToDate = false
                    pullUpLabel.text = "PULL UP FOR FRESH DATA"
                    pullUpLabel.textColor = hintColor
                }
            } else {
                pullUpLabel.text = "PULL UP FOR FRESH DATA"
                pullUpLabel.textColor = hintColor
            }
            
            hasTriggeredHaptic = false
        }
    }
    
    func animateWeatherCardAppearance(for card: UIView, delay: TimeInterval) {
        card.alpha = 0
        card.transform = CGAffineTransform(translationX: 0, y: 60).scaledBy(x: 0.85, y: 0.85)
        UIView.animate(withDuration: 1.0, delay: delay, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut) {
            card.alpha = 1
            card.transform = .identity
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let pullDistance = (scrollView.contentOffset.y + scrollView.frame.size.height) - scrollView.contentSize.height
        
        if pullDistance > triggerThreshold && !isFetching {
            UIView.animate(withDuration: 0.3) {
                scrollView.contentInset.bottom = self.footerHeight
            }
            loadRemoteWeatherData(isManual: true)
        } else if !isFetching && pullDistance <= triggerThreshold {
            hasTriggeredHaptic = false
        }
    }

    private func updateLastSyncedTimestamp() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm:ss a"
        lastSyncedLabel.text = "Last Synced: \(formatter.string(from: Date()))"
    }

    @objc func handleZoomTap(_ gesture: UITapGestureRecognizer) {
        guard let tappedView = gesture.view else { return }
        let index = tappedView.tag
        guard weatherEntries.indices.contains(index) else { return }
        
        let entry = weatherEntries[index]
        
        let zoomVC = ZoomAnimationViewController()
        zoomVC.headline = entry.locationName
        zoomVC.subheadline = entry.timestamp
        zoomVC.imageName = entry.imageName
        zoomVC.humidity = entry.humidity
        zoomVC.pressure = entry.pressure
        zoomVC.detailedDescription = entry.description
        zoomVC.isErrorState = errorCardIndexes.contains(index)
        
        present(zoomVC, animated: true)
    }

    @objc func dismissVC() { dismiss(animated: true) }
}

extension UIImageView {
    func loadRemoteImage(from url: URL) {
        let cacheKey = NSString(string: url.absoluteString)
        if let cachedImage = ImageCache.shared.object(forKey: cacheKey) {
            self.image = cachedImage
            return
        }
        
        let loader = UIHostingController(rootView: LottieImageLoader())
        loader.view.backgroundColor = .clear
        loader.view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(loader.view)
        NSLayoutConstraint.activate([
            loader.view.centerXAnchor.constraint(equalTo: centerXAnchor),
            loader.view.centerYAnchor.constraint(equalTo: centerYAnchor),
            loader.view.widthAnchor.constraint(equalToConstant: 80),
            loader.view.heightAnchor.constraint(equalToConstant: 80)
        ])

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            DispatchQueue.main.async {
                loader.view.removeFromSuperview()
                guard let self else { return }
                if let data = data, let image = UIImage(data: data) {
                    ImageCache.shared.setObject(image, forKey: cacheKey)
                    UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        self.image = image
                    }, completion: nil)
                }
            }
        }.resume()
    }
}
