//
//  ContentView.swift
//  COM Weather
//
//  Created by Victor Rosales  on 2/12/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        ZStack{
            Color(.gray)
                .ignoresSafeArea()
            
            
            VStack{
                Image("banner1").resizable().scaledToFit().cornerRadius(60)
                    .padding(.top, 30)
                Text("Welcome to College of Marin Weather App!")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding()
                    .foregroundColor(Color.white)
                Image("sunny").resizable().scaledToFit().cornerRadius(90)
                    .frame(width: 300, height: 300)
                    .shadow(radius: 10)
                    
                    .padding(.top,0)
                Text("Currently Sunny !")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding(-20)
                    .foregroundColor(Color.white)
                Spacer()
            }
            .padding(20)
            
        }
    }
}

#Preview {
    ContentView()
}
