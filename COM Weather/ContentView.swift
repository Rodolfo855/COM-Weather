import SwiftUI
import UIKit

// MARK: - 1. CUSTOM BUTTON STYLE
// Adds a nice scaling effect when the user taps the buttons
struct ModernButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var foregroundColor: Color
    var isOutlined: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isOutlined ? Color.clear : backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(foregroundColor, lineWidth: isOutlined ? 2 : 0)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .shadow(color: isOutlined ? .clear : .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

// MARK: - 2. MAIN CONTENT VIEW
struct ContentView: View {
    @State private var showWeather = false
    @State private var showNewsletter = false
    
    var body: some View {
        ZStack {
            // Dark professional gradient
            LinearGradient(gradient: Gradient(colors: [Color(white: 0.15), Color.black]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header Image
                Image("banner1")
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(30)
                    .shadow(color: .blue.opacity(0.3), radius: 20)
                    .padding(.top, 20)
                
                // Welcome Text
                VStack(spacing: 4) {
                    Text("College of Marin")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                    Text("Weather & Campus News")
                        .font(.title3)
                        .fontWeight(.light)
                }
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                
                // Hero Weather Icon
                Image("sunny")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .shadow(color: .orange.opacity(0.4), radius: 30)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: { showWeather = true }) {
                        HStack {
                            Image(systemName: "thermometer.sun.fill")
                            Text("Check Live Weather")
                        }
                    }
                    .buttonStyle(ModernButtonStyle(backgroundColor: .white, foregroundColor: .black))
                    .sheet(isPresented: $showWeather) {
                        WeatherViewControllerWrapper()
                    }
                    
                    Button(action: { showNewsletter = true }) {
                        HStack {
                            Image(systemName: "newspaper.fill")
                            Text("Campus Newsletter")
                        }
                    }
                    .buttonStyle(ModernButtonStyle(backgroundColor: .white, foregroundColor: .white, isOutlined: true))
                    .sheet(isPresented: $showNewsletter) {
                        NewsletterViewControllerWrapper()
                    }
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 30)
        }
    }
}

// MARK: - 3. WEATHER VIEW (CARD LAYOUT)
struct WeatherViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return WeatherViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

class WeatherViewController: UIViewController {
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.94, alpha: 1)
        setupLayout()
        
        let data = [
            ("Kentfield Campus", "68°F - Sunny", "banner1"),
            ("Indian Valley", "65°F - Partial Clouds", "sunny"),
            ("Science Village", "67°F - Clear Skies", "image3"),
            ("Miwok Center", "70°F - High UV", "image4"),
            ("Football Field", "66°F - Breezy", "image5")
        ]
        
        for item in data {
            let card = createWeatherCard(title: item.0, sub: item.1, img: item.2)
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
        stackView.spacing = 20
        stackView.alignment = .center
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 30),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -30),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func createWeatherCard(title: String, sub: String, img: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 20
        card.layer.shadowOpacity = 0.1; card.layer.shadowRadius = 10; card.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        let iv = UIImageView(image: UIImage(named: img) ?? UIImage(systemName: "cloud.fill"))
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true; iv.layer.cornerRadius = 12
        
        let lb = UILabel()
        lb.text = title; lb.font = .boldSystemFont(ofSize: 20)
        
        let sb = UILabel()
        sb.text = sub; sb.font = .systemFont(ofSize: 16); sb.textColor = .systemBlue
        
        [iv, lb, sb].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; card.addSubview($0) }
        
        NSLayoutConstraint.activate([
            iv.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            iv.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            iv.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            iv.heightAnchor.constraint(equalToConstant: 160),
            lb.topAnchor.constraint(equalTo: iv.bottomAnchor, constant: 10),
            lb.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
            sb.topAnchor.constraint(equalTo: lb.bottomAnchor, constant: 4),
            sb.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
            sb.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -15)
        ])
        return card
    }
}

// MARK: - 4. NEWSLETTER VIEW (LIST LAYOUT)
struct NewsletterViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return NewsletterViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

class NewsletterViewController: UIViewController {
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        
        let news = [
            ("New Library Hours", "Extended until 10 PM for finals.", "image3"),
            ("Scholarship Deadline", "Apply by next Friday at noon.", "image4"),
            ("Cafeteria Special", "Taco Tuesday returns to COM!", "image5"),
            ("Career Fair", "Meet local employers in the gym.", "banner1"),
            ("Parking Update", "Lot C is now open for students.", "sunny")
        ]
        
        for item in news {
            addNewsRow(title: item.0, body: item.1, imgName: item.2)
        }
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 1
        stackView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func addNewsRow(title: String, body: String, imgName: String) {
        let row = UIView()
        row.backgroundColor = .white
        
        let img = UIImageView(image: UIImage(named: imgName) ?? UIImage(systemName: "doc.text.fill"))
        img.contentMode = .scaleAspectFill; img.clipsToBounds = true; img.layer.cornerRadius = 8
        
        let t = UILabel(); t.text = title; t.font = .boldSystemFont(ofSize: 17)
        let b = UILabel(); b.text = body; b.font = .systemFont(ofSize: 14); b.textColor = .gray; b.numberOfLines = 2
        
        [img, t, b].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; row.addSubview($0) }
        
        NSLayoutConstraint.activate([
            img.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 15),
            img.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            img.widthAnchor.constraint(equalToConstant: 70),
            img.heightAnchor.constraint(equalToConstant: 70),
            
            t.topAnchor.constraint(equalTo: row.topAnchor, constant: 15),
            t.leadingAnchor.constraint(equalTo: img.trailingAnchor, constant: 12),
            t.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -15),
            
            b.topAnchor.constraint(equalTo: t.bottomAnchor, constant: 4),
            b.leadingAnchor.constraint(equalTo: t.leadingAnchor),
            b.trailingAnchor.constraint(equalTo: t.trailingAnchor),
            b.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -15)
        ])
        stackView.addArrangedSubview(row)
    }
}

// MARK: - PREVIEW
#Preview {
    ContentView()
}
