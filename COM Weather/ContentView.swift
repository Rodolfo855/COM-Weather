import SwiftUI
import UIKit
import AVKit

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
            // Background
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
            case .map: Text("Map View Coming Soon").presentationDetents([.medium])
            }
        }
    }
    
    // --- Sub-views to help the compiler ---
    
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
        Image("sunny")
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

// MARK: - 3. WEATHER VIEW (CARD INTERFACE)
struct WeatherViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController { WeatherViewController() }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

class WeatherViewController: UIViewController {
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.94, alpha: 1.0)
        setupLayout()
        
        let weatherData = [
            ("Kentfield Campus", "68°F - Sunny & Clear", "banner1"),
            ("Indian Valley", "64°F - Slight Breeze", "sunny"),
            ("Science Village", "67°F - Optimal Humidity", "image3"),
            ("Miwok Center", "71°F - High UV Index", "image4"),
            ("Athletic Fields", "65°F - Wind: 5mph NW", "image5")
        ]
        
        for item in weatherData {
            let card = createWeatherCard(title: item.0, subtext: item.1, imgName: item.2)
            stackView.addArrangedSubview(card)
            card.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.9).isActive = true
        }
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 25
        stackView.alignment = .center
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 30),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -30),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    private func createWeatherCard(title: String, subtext: String, imgName: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.12
        card.layer.shadowOffset = CGSize(width: 0, height: 8)
        card.layer.shadowRadius = 10
        
        let iv = UIImageView(image: UIImage(named: imgName) ?? UIImage(systemName: "cloud.sun.fill"))
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 15
        
        let tLabel = UILabel()
        tLabel.text = title
        tLabel.font = .systemFont(ofSize: 22, weight: .bold)
        
        let sLabel = UILabel()
        sLabel.text = subtext
        sLabel.font = .systemFont(ofSize: 16)
        sLabel.textColor = .systemBlue
        
        let updateLabel = UILabel()
        updateLabel.text = "Last updated: \(getCurrentTime())"
        updateLabel.font = .systemFont(ofSize: 12, weight: .medium)
        updateLabel.textColor = .lightGray
        
        [iv, tLabel, sLabel, updateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            iv.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            iv.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            iv.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            iv.heightAnchor.constraint(equalToConstant: 180),
            
            tLabel.topAnchor.constraint(equalTo: iv.bottomAnchor, constant: 12),
            tLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
            
            sLabel.topAnchor.constraint(equalTo: tLabel.bottomAnchor, constant: 4),
            sLabel.leadingAnchor.constraint(equalTo: tLabel.leadingAnchor),
            
            updateLabel.topAnchor.constraint(equalTo: sLabel.bottomAnchor, constant: 8),
            updateLabel.leadingAnchor.constraint(equalTo: tLabel.leadingAnchor),
            updateLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])
        return card
    }
    
    private func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }
}

// MARK: - 4. NEWSLETTER VIEW (SOCIAL FEED)
struct NewsletterViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController { NewsletterViewController() }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

class NewsletterViewController: UIViewController, UITableViewDataSource {
    let tableView = UITableView()
    let items = [
        ("video", "STUDENT LIFE", "Spring Festival", "The quad was buzzing today!", "sunny"),
        ("image", "ACADEMICS", "Library Update", "New study pods are now available.", "banner1"),
        ("image", "SPORTS", "Soccer Victory", "Mariners won 2-0!", "image5")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Campus Feed"
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(FeedCell.self, forCellReuseIdentifier: "FeedCell")
        view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        let i = items[indexPath.row]
        cell.configure(tag: i.1, title: i.2, body: i.3, imgName: i.4, isVideo: i.0 == "video")
        return cell
    }
}

class FeedCell: UITableViewCell {
    let card = UIView()
    let iv = UIImageView()
    let play = UIImageView(image: UIImage(systemName: "play.circle.fill"))
    let tagL = UILabel()
    let titleL = UILabel()
    let bodyL = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) { fatalError("!") }

    func setup() {
        selectionStyle = .none
        backgroundColor = .clear
        card.backgroundColor = .white
        card.layer.cornerRadius = 20
        card.clipsToBounds = true
        
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        
        tagL.font = .systemFont(ofSize: 12, weight: .bold)
        tagL.textColor = .systemCyan
        
        titleL.font = .systemFont(ofSize: 20, weight: .bold)
        
        bodyL.font = .systemFont(ofSize: 14)
        bodyL.textColor = .gray
        bodyL.numberOfLines = 2
        
        play.tintColor = .white
        
        contentView.addSubview(card)
        [iv, tagL, titleL, bodyL, play].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview($0)
        }
        card.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            iv.topAnchor.constraint(equalTo: card.topAnchor),
            iv.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            iv.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            iv.heightAnchor.constraint(equalToConstant: 220),
            
            play.centerXAnchor.constraint(equalTo: iv.centerXAnchor),
            play.centerYAnchor.constraint(equalTo: iv.centerYAnchor),
            play.widthAnchor.constraint(equalToConstant: 50),
            play.heightAnchor.constraint(equalToConstant: 50),
            
            tagL.topAnchor.constraint(equalTo: iv.bottomAnchor, constant: 15),
            tagL.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
            
            titleL.topAnchor.constraint(equalTo: tagL.bottomAnchor, constant: 5),
            titleL.leadingAnchor.constraint(equalTo: tagL.leadingAnchor),
            
            bodyL.topAnchor.constraint(equalTo: titleL.bottomAnchor, constant: 5),
            bodyL.leadingAnchor.constraint(equalTo: tagL.leadingAnchor),
            bodyL.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -15)
        ])
    }
    
    func configure(tag: String, title: String, body: String, imgName: String, isVideo: Bool) {
        tagL.text = tag
        titleL.text = title
        bodyL.text = body
        iv.image = UIImage(named: imgName) ?? UIImage(systemName: "photo")
        play.isHidden = !isVideo
    }
}

// MARK: - PREVIEW
#Preview {
    ContentView()
}
