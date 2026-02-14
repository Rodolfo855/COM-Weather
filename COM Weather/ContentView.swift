import SwiftUI
import UIKit
import AVKit
import AVFoundation
import MapKit

// MARK: - 1. MODERN BUTTON STYLE
struct ModernButtonStyle: ButtonStyle {
    var color: Color
    var isOutlined: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isOutlined ? Color.clear : color)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color, lineWidth: isOutlined ? 2 : 0)
            )
            .foregroundColor(isOutlined ? color : .black)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .shadow(color: isOutlined ? .clear : color.opacity(0.3), radius: 10, y: 5)
            .animation(.spring(), value: configuration.isPressed)
    }
}

// MARK: - 2. MAIN DASHBOARD
struct ContentView: View {
    @State private var activeSheet: SheetType?
    
    enum SheetType: Identifiable {
        case weather, newsletter, map
        var id: Int { hashValue }
    }
    
    var body: some View {
        ZStack {
            Color(white: 0.05).ignoresSafeArea()
            
            VStack(spacing: 25) {
                headerView
                heroView
                Spacer()
                buttonStack
            }
            .padding(30)
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .weather: WeatherViewControllerWrapper()
            case .newsletter: NewsletterViewControllerWrapper()
            case .map: CampusMapView()
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 15) {
            Image("banner1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 4))
            
            VStack(spacing: 8) {
                Text("College of Marin")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                Text("By: Victor Rosales")
                    .font(.caption)
                    .kerning(4)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
        }
    }
    
    private var heroView: some View {
        Image("100")
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)
            .shadow(color: .orange.opacity(0.4), radius: 30)
    }
    
    private var buttonStack: some View {
        VStack(spacing: 18) {
            Button(action: { activeSheet = .weather }) {
                Label("Live Weather", systemImage: "cloud.sun.fill")
            }.buttonStyle(ModernButtonStyle(color: .white))
            
            Button(action: { activeSheet = .newsletter }) {
                Label("Campus Feed", systemImage: "newspaper.fill")
            }.buttonStyle(ModernButtonStyle(color: .cyan))
            
            Button(action: { activeSheet = .map }) {
                Label("Campus Map", systemImage: "map.fill")
            }.buttonStyle(ModernButtonStyle(color: .white, isOutlined: true))
        }
        .padding(.bottom, 40)
    }
}

// MARK: - 3. WEATHER VIEW
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
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -40),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    private func createWeatherCard(title: String, subtext: String, imgName: String, locLabel: String) -> UIView {
        let card = UIView(); card.backgroundColor = .white; card.layer.cornerRadius = 20
        let iv = UIImageView(image: UIImage(named: imgName) ?? UIImage(systemName: "photo"))
        iv.contentMode = .scaleAspectFill; iv.clipsToBounds = true; iv.layer.cornerRadius = 15
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        blur.layer.cornerRadius = 8; blur.clipsToBounds = true
        let lTag = UILabel(); lTag.text = locLabel; lTag.font = .systemFont(ofSize: 10, weight: .black); lTag.textColor = .white
        
        let tLabel = UILabel(); tLabel.text = title; tLabel.font = .boldSystemFont(ofSize: 22)
        let sLabel = UILabel(); sLabel.text = subtext; sLabel.textColor = .systemBlue
        let syncLabel = UILabel(); syncLabel.text = "Synced: \(Date().formatted(date: .omitted, time: .shortened))"; syncLabel.font = .systemFont(ofSize: 12); syncLabel.textColor = .lightGray
        
        [iv, tLabel, sLabel, syncLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; card.addSubview($0) }
        iv.addSubview(blur); blur.contentView.addSubview(lTag)
        blur.translatesAutoresizingMaskIntoConstraints = false; lTag.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iv.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            iv.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            iv.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            iv.heightAnchor.constraint(equalToConstant: 180),
            blur.leadingAnchor.constraint(equalTo: iv.leadingAnchor, constant: 10),
            blur.bottomAnchor.constraint(equalTo: iv.bottomAnchor, constant: -10),
            lTag.topAnchor.constraint(equalTo: blur.contentView.topAnchor, constant: 5),
            lTag.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor, constant: -5),
            lTag.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor, constant: 8),
            lTag.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor, constant: -8),
            tLabel.topAnchor.constraint(equalTo: iv.bottomAnchor, constant: 12),
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

// MARK: - 4. NEWSLETTER VIEW
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
        view.backgroundColor = .white
        
        tableView.dataSource = self; tableView.delegate = self
        tableView.register(FeedCell.self, forCellReuseIdentifier: "FeedCell")
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
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
        let extensions = ["mp4", "MOV", "m4v"]
        var videoURL: URL?
        
        // 1. Try to find local file
        for ext in extensions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                videoURL = url
                break
            }
        }
        
        // 2. FALLBACK: Use a remote URL for testing if local file is missing
        if videoURL == nil {
            videoURL = URL(string: "https://web.archive.org/web/20230526183015/https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4")
        }
        
        guard let finalURL = videoURL else { return }
        
        let player = AVPlayer(url: finalURL)
        let pc = AVPlayerViewController()
        pc.player = player
        present(pc, animated: true) { player.play() }
    }
}

// MARK: - 5. CAMPUS MAP VIEW (Compiler Fix)
struct CampusMapView: View {
    @Environment(\.dismiss) var dismiss
    
    // Modern Map Camera Position
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.9532, longitude: -122.5511),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )
    
    var body: some View {
        NavigationStack {
            Map(position: $position) {
                Marker("College of Marin", coordinate: CLLocationCoordinate2D(latitude: 37.9532, longitude: -122.5511))
                    .tint(.red)
            }
            .navigationTitle("Campus Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(.black)
                }
            }
        }
    }
}

// MARK: - FEED CELL
class FeedCell: UITableViewCell {
    let card = UIView(); let iv = UIImageView(); let play = UIImageView(image: UIImage(systemName: "play.circle.fill"))
    let tagL = UILabel(); let titleL = UILabel(); let bodyL = UILabel(); let locBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    let locL = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier); setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    func setup() {
        selectionStyle = .none; card.backgroundColor = UIColor(white: 0.98, alpha: 1); card.layer.cornerRadius = 20; card.clipsToBounds = true
        iv.contentMode = .scaleAspectFill; iv.clipsToBounds = true; play.tintColor = .white
        locBlur.layer.cornerRadius = 6; locBlur.clipsToBounds = true
        locL.font = .systemFont(ofSize: 9, weight: .bold); locL.textColor = .white
        tagL.font = .boldSystemFont(ofSize: 12); tagL.textColor = .systemCyan
        titleL.font = .boldSystemFont(ofSize: 18); titleL.textColor = .black
        bodyL.font = .systemFont(ofSize: 14); bodyL.numberOfLines = 2; bodyL.textColor = .darkGray
        
        contentView.addSubview(card)
        [iv, tagL, titleL, bodyL, play].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; card.addSubview($0) }
        iv.addSubview(locBlur); locBlur.contentView.addSubview(locL)
        locBlur.translatesAutoresizingMaskIntoConstraints = false; locL.translatesAutoresizingMaskIntoConstraints = false
        card.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            iv.topAnchor.constraint(equalTo: card.topAnchor), iv.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            iv.trailingAnchor.constraint(equalTo: card.trailingAnchor), iv.heightAnchor.constraint(equalToConstant: 200),
            locBlur.leadingAnchor.constraint(equalTo: iv.leadingAnchor, constant: 10),
            locBlur.bottomAnchor.constraint(equalTo: iv.bottomAnchor, constant: -10),
            locL.topAnchor.constraint(equalTo: locBlur.contentView.topAnchor, constant: 4),
            locL.bottomAnchor.constraint(equalTo: locBlur.contentView.bottomAnchor, constant: -4),
            locL.leadingAnchor.constraint(equalTo: locBlur.contentView.leadingAnchor, constant: 6),
            locL.trailingAnchor.constraint(equalTo: locBlur.contentView.trailingAnchor, constant: -6),
            play.centerXAnchor.constraint(equalTo: iv.centerXAnchor), play.centerYAnchor.constraint(equalTo: iv.centerYAnchor),
            play.widthAnchor.constraint(equalToConstant: 50), play.heightAnchor.constraint(equalToConstant: 50),
            tagL.topAnchor.constraint(equalTo: iv.bottomAnchor, constant: 12), tagL.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
            titleL.topAnchor.constraint(equalTo: tagL.bottomAnchor, constant: 4), titleL.leadingAnchor.constraint(equalTo: tagL.leadingAnchor),
            bodyL.topAnchor.constraint(equalTo: titleL.bottomAnchor, constant: 4), bodyL.leadingAnchor.constraint(equalTo: tagL.leadingAnchor),
            bodyL.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -15)
        ])
    }
    
    func configure(tag: String, title: String, body: String, imgName: String, isVideo: Bool, loc: String) {
        tagL.text = tag; titleL.text = title; bodyL.text = body; locL.text = loc
        iv.image = UIImage(named: imgName) ?? UIImage(systemName: "photo"); play.isHidden = !isVideo
    }
}

#Preview { ContentView() }
