import SwiftUI

struct ContentView: View {
    @State private var activeSheet: SheetType?
    
    enum SheetType: String, Identifiable {
        case weather, newsletter, map
        var id: String { self.rawValue }
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

#Preview {
    ContentView()
}
