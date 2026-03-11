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
                            .foregroundColor(.green.opacity(1.8))
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
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
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
//#Preview {
//    LiquidGlassEffectContainer()
//        .preferredColorScheme(.dark)
//}
