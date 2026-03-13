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
        LottieView(animation: .named("imageLoading"))
            .playbackMode(.playing(.toProgress(1, loopMode: .repeat(.infinity))))
            .resizable() // Recommended so you can frame it
            .frame(width: 200, height: 200)
    }
}

//#Preview() {
//    LottieImageLoader()
//}
