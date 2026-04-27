//
//  ImageLoaderAnimation.swift
//  COM Weather
//
//  Created by Victor Rosales  on 3/12/26.
//
import SwiftUI
import Lottie

struct LottieImageLoader: View {
    var body: some View {
        LottieView(animation: .named("loading"))
            .playbackMode(.playing(.toProgress(1, loopMode: .repeat(.infinity))))
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

#Preview {
    LottieImageLoader()
}
