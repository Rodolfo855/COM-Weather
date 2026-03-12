//
//  StatsForNerds.swift
//  COM Weather
//
//  Created by Victor Rosales  on 3/9/26.
//

import SwiftUI

struct LiquidGlassEffectContainer: View {
    @State private var morph = false
    @State private var showDeveloping = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GlassEffectContainer(spacing: 50) {
            ZStack {
                Image("hardwareHome")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    if !showDeveloping {
                        AnimatedLogo()
                            .blendMode(.screen)
                            //.scaleEffect(morph ? 1.05 : 0.95)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: morph)
                            //.padding(.bottom, 20)
                            
                        HStack(spacing: morph ? 50.0 : -15.0) {
                            Button {
                            } label: {
                                Image(systemName: "cpu")
                            }
                            .padding()
                            .glassEffect(.clear)
                            
                            Button {
                            } label: {
                                Image(systemName: "ant.circle.fill")
                            }
                            .padding()
                            .glassEffect(.clear)
                        }
                        .tint(.green)
                        .font(.system(size: 64.0))
                        .animation(
                            Animation
                                .easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true)
                                .delay(0.5),
                            value: morph
                        )
                        
                        Text("Fetching data")
                            .font(.system(size: 26.0, weight: .black, design: .monospaced))
                            .foregroundColor(.green.opacity(0.8))
                            .opacity(morph ? 1.0 : 0.4)
                            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: morph)
                    } else {
                        Text("Coming Soon!")
                            .font(.system(size: 26.0, weight: .black, design: .monospaced))
                            .foregroundColor(.green)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .onAppear {
                    self.morph.toggle()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
                        print("Developing")
                        withAnimation {
                            self.showDeveloping = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

struct AnimatedLogo: View {
    var body: some View {
        ZStack {
            Image("logoStats")
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 400)
                .scaleEffect(2)
                .phaseAnimator([0, 360]) { content, angle in
                    content.rotationEffect(.degrees(angle))
                } animation: { _ in
                    .linear(duration: 7).repeatForever(autoreverses: false)
                }

            VStack(spacing: 2) {
                Text("By:")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(1.5))
                
                Text("Victor R")
                    .font(.system(size: 26, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
            }
            .offset(y: -5)
        }
    }
}

#Preview {
    LiquidGlassEffectContainer()
        .preferredColorScheme(.dark)
}
