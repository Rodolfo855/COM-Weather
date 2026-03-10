//
//  StatsForNerds.swift
//  COM Weather
//
//  Created by Victor Rosales  on 3/9/26.
//

import SwiftUI

struct LiquidGlassEffectContainer: View {
    @State private var morph = false
    
    var body: some View {
        GlassEffectContainer(spacing: 50) {
            ZStack {
                Image("hardwareHome")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    HStack(spacing: morph ? 50.0 : -15.0) {
                        Button {
                        } label: {
                            Image(systemName: "cpu")
                        }
                        .padding()
                        .glassEffect()
                        
                        Button {
                        } label: {
                            Image(systemName: "ant.circle.fill")
                        }
                        .padding()
                        .glassEffect()
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
                }
                .onAppear {
                    self.morph.toggle()
                }
            }
        }
    }
}

//#Preview {
//    LiquidGlassEffectContainer()
//        .preferredColorScheme(.dark)
//}
