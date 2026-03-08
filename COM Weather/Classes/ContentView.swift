import SwiftUI

// MARK: Struct for the College of Marin Home Page
struct MarinLogoShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: w * 0.15, y: h * 0.85)) // Bottom Left
        path.addLine(to: CGPoint(x: w * 0.15, y: h * 0.15)) // Top Left
        path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.5))   // Middle Dip
        path.addLine(to: CGPoint(x: w * 0.85, y: h * 0.15)) // Top Right
        path.addLine(to: CGPoint(x: w * 0.85, y: h * 0.85)) // Bottom Right
        
        return path
    }
}

// MARK: Struct for College of Marin Home Page version 2
struct ModernMLogo: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.1))
                .blur(radius: 20)
            
            GeometryReader { geometry in
                let w = geometry.size.width
                let h = geometry.size.height
                
                Path { path in
                    // Start Bottom Left
                    path.move(to: CGPoint(x: w * 0.2, y: h * 0.8))
                    // Up to Top Left
                    path.addLine(to: CGPoint(x: w * 0.2, y: h * 0.25))
                    // Down to Center
                    path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.6))
                    // Up to Top Right
                    path.addLine(to: CGPoint(x: w * 0.8, y: h * 0.25))
                    // Down to Bottom Right
                    path.addLine(to: CGPoint(x: w * 0.8, y: h * 0.8))
                }
                .stroke(
                    LinearGradient(
                        colors: [.white, .cyan, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round, lineJoin: .round)
                )
                .shadow(color: .cyan.opacity(0.4), radius: 8)
                
                Path { path in
                    path.move(to: CGPoint(x: w * 0.2, y: h * 0.4))
                    path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.6))
                    path.addLine(to: CGPoint(x: w * 0.8, y: h * 0.4))
                }
                .stroke(Color.white.opacity(0.3), lineWidth: 4)
            }
            .frame(width: 140, height: 200)
        }
        .frame(width: 200, height: 200)
        .background(Color.white.opacity(0.05))
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 4))
    }
}

struct ModernMLogo2: View {
    @State private var drawingProgress: CGFloat = 0.0
    @State private var isPulsing: Bool = false
    
    var body: some View {
        ZStack {
            // Central Container for the M
            ZStack {
                GeometryReader { geometry in
                    let w = geometry.size.width
                    let h = geometry.size.height
                    
                    let mPath = Path { path in
                        path.move(to: CGPoint(x: w * 0.1, y: h * 0.9))
                        path.addLine(to: CGPoint(x: w * 0.1, y: h * 0.1))
                        path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.6))
                        path.addLine(to: CGPoint(x: w * 0.9, y: h * 0.1))
                        path.addLine(to: CGPoint(x: w * 0.9, y: h * 0.9))
                    }
                    
                    ZStack {
                        mPath
                            .stroke(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: 22, lineCap: .round, lineJoin: .round))

                        // Flows forwaard
                        mPath
                            .trim(from: drawingProgress, to: drawingProgress + 0.3)
                            .stroke(
                                LinearGradient(colors: [.white, .cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                style: StrokeStyle(lineWidth: 22, lineCap: .round, lineJoin: .round)
                            )
                            .shadow(color: Color.cyan.opacity(isPulsing ? 0.8 : 0.4), radius: 12)

                        // 3. Animated M Current (Loop Filler)
                        mPath
                            .trim(from: drawingProgress - 1.0, to: drawingProgress - 0.7)
                            .stroke(
                                LinearGradient(colors: [.white, .cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                style: StrokeStyle(lineWidth: 22, lineCap: .round, lineJoin: .round)
                            )
                            .shadow(color: Color.cyan.opacity(isPulsing ? 0.8 : 0.4), radius: 12)
                    }
                }
                .frame(width: 140, height: 140)
            }
            .frame(width: 200, height: 200)
        }
        .frame(width: 200, height: 200)
        .background(Color.white.opacity(0.05))
        .clipShape(Circle())
        .overlay(
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 4)
                
                // Animated Outer Arc
                Circle()
                    .trim(from: drawingProgress, to: drawingProgress + 0.2)
                    .stroke(
                        LinearGradient(colors: [.cyan, .blue, .clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: Color.cyan.opacity(isPulsing ? 1.0 : 0.5), radius: 5)
            }
        )
        .onAppear {
            withAnimation(Animation.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                self.drawingProgress = 1.0
            }
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                self.isPulsing = true
            }
        }
    }
}

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
                case .weather:
                    WeatherViewControllerWrapper()
                        .ignoresSafeArea(edges: .bottom) 
                case .newsletter:
                    NewsletterViewControllerWrapper()
                        .ignoresSafeArea(edges: .bottom)
                case .map:
                    CampusMapView()
                        .ignoresSafeArea(edges: .bottom)
                }
            }
    }
    
    private var headerView: some View {
        VStack(spacing: 15) {
//            Image("banner1")
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(width: 200, height: 200)
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 4))
//            MarinLogoShape()
//                .stroke(LinearGradient(colors: [.white, .blue], startPoint: .top, endPoint: .bottom),
//                    style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
//                        .frame(width: 150, height: 150)
//                        .padding(25)
//                        .background(Color.white.opacity(0.05))
//                        .clipShape(Circle())
//
            //ModernMLogo()
            ModernMLogo2()
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
            }.buttonStyle(ModernButtonStyle(color: .white.opacity(  1.0)))
            
            Button(action: { activeSheet = .newsletter }) {
                Label("Campus Feed", systemImage: "newspaper.fill")
            }.buttonStyle(ModernButtonStyle(color: .cyan))
            
            Button(action: { activeSheet = .map }) {
                Label("Campus Map", systemImage: "map.fill")
            }.buttonStyle(ModernButtonStyle(color: .white, isOutlined: true))
            
            Button(action: {activeSheet = nil}){
                Label("Stats for nerds", systemImage: "chart.bar.fill")
            }.buttonStyle(ModernButtonStyle(color: .indigo.opacity(1.0)))
        }
        .padding(.bottom, 40)
    }
}

//#Preview {
//    ContentView()
//}
