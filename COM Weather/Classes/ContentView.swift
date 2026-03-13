//
//  ContentView.swift
//  COM Weather
//
//  Created by Victor Rosales on 2/14/26.
//

import SwiftUI

struct MarinLogoShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: w * 0.15, y: h * 0.85))
        path.addLine(to: CGPoint(x: w * 0.15, y: h * 0.15))
        path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.5))
        path.addLine(to: CGPoint(x: w * 0.85, y: h * 0.15))
        path.addLine(to: CGPoint(x: w * 0.85, y: h * 0.85))
        
        return path
    }
}

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
                    path.move(to: CGPoint(x: w * 0.2, y: h * 0.8))
                    path.addLine(to: CGPoint(x: w * 0.2, y: h * 0.25))
                    path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.6))
                    path.addLine(to: CGPoint(x: w * 0.8, y: h * 0.25))
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
    let isAnimating: Bool
    @State private var drawingProgress: CGFloat = 0.0
    @State private var isPulsing: Bool = false
    @State private var logoOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
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

                        mPath
                            .trim(from: drawingProgress - 1.0, to: drawingProgress - 0.7)
                            .stroke(
                                LinearGradient(colors: [.white, .cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                style: StrokeStyle(lineWidth: 22, lineCap: .round, lineJoin: .round)
                            )
                            .shadow(color: Color.cyan.opacity(isPulsing ? 0.0 : 1.3), radius: 12)
                        
                        mPath
                            .trim(from: drawingProgress, to: drawingProgress + 0.3)
                            .stroke(
                                LinearGradient(colors: [.white, .cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                style: StrokeStyle(lineWidth: 22, lineCap: .round, lineJoin: .round)
                            )
                            .shadow(color: Color.cyan.opacity(isPulsing ? 0.0 : 1.3), radius: 12)

                        mPath
                            .trim(from: drawingProgress + 1.0, to: drawingProgress + 1.3)
                            .stroke(
                                LinearGradient(colors: [.white, .cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                style: StrokeStyle(lineWidth: 22, lineCap: .round, lineJoin: .round)
                            )
                    }
                }
                .frame(width: 140, height: 140)
            }
            .frame(width: 200, height: 200)
        }
        .frame(width: 200, height: 200)
        .background(Color.white.opacity(0.05))
        .clipShape(Circle())
        .opacity(logoOpacity)
        .overlay(
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 4)
                
                Circle()
                    .trim(from: 0, to: 0.15)
                    .stroke(
                        LinearGradient(colors: [.white, .white, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .rotationEffect(.degrees(Double(drawingProgress) * 360))
                    .shadow(color: Color.cyan.opacity(isPulsing ? 1.0 : 0.5), radius: 5)
            }
        )
        .onChange(of: isAnimating, initial: true) { _, newValue in
            if newValue {
                withAnimation(.easeIn(duration: 0.8)) {
                    self.logoOpacity = 1.0
                }
                withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                    self.drawingProgress = 1.0
                }
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    self.isPulsing = true
                }
            } else {
                withAnimation(.easeOut(duration: 0.4)) {
                    self.logoOpacity = 0.0
                    self.drawingProgress = 0.0
                    self.isPulsing = false
                }
            }
        }
    }
}

struct ContentView: View {
    @State private var activeSheet: SheetType?
    
    enum SheetType: String, Identifiable {
        case weather, newsletter, map, stats
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
        .fullScreenCover(item: $activeSheet) { item in
            switch item {
                case .weather:
                    WeatherViewControllerWrapper()
                        .ignoresSafeArea(edges: .bottom)
                        .ignoresSafeArea(edges: .top)
                case .newsletter:
                    NewsletterViewControllerWrapper()
                        .ignoresSafeArea(edges: .bottom)
                        .ignoresSafeArea(edges: .top)
                case .map:
                    CampusMapView()
                        .ignoresSafeArea(edges: .bottom)
                        .ignoresSafeArea(edges: .top)
                case .stats:
                    LiquidGlassEffectContainer()
                }
            }
    }
    
    private var headerView: some View {
        VStack(spacing: 15) {
            ModernMLogo2(isAnimating: activeSheet == nil)
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
            .opacity(activeSheet == nil ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.5), value: activeSheet)
    }
    
    private var buttonStack: some View {
        VStack(spacing: 18) {
            Button(action: { activeSheet = .weather }) {
                Label("Live Weather", systemImage: "cloud.sun.fill")
            }.buttonStyle(ModernButtonStyle(color: .white.opacity(1.2)))
            
            Button(action: { activeSheet = .newsletter }) {
                Label("Campus Feed", systemImage: "newspaper.fill")
            }.buttonStyle(ModernButtonStyle(color: .cyan.opacity( 1.2)))
            
            Button(action: { activeSheet = .map }) {
                Label("Campus Map", systemImage: "map.fill")
            }.buttonStyle(ModernButtonStyle(color: .white.opacity(  1.2), isOutlined: true))
            
            Button(action: { activeSheet = .stats }){
                Label("Stats for nerds", systemImage: "chart.bar.fill")
            }.buttonStyle(ModernButtonStyle(color: .indigo.opacity(1.4)))
        }
        .padding(.bottom, 0)
    }
}
