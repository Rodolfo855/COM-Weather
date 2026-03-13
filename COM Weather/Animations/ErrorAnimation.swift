//
//  Error404.swift
//  COM Weather
//
//  Created by Victor Rosales  on 3/12/26.
//

import SwiftUI
import Lottie

struct LottieErrorAnimationView: View {
    var body: some View {
        LottieView(animation: .named("Error404"))
            .playbackMode(.playing(.toProgress(1, loopMode: .repeat(.infinity))))
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
