//
//  ModernButtonStyle.swift
//  COM Weather
//
//  Created by Victor Rosales  on 2/14/26.
//

import SwiftUI

struct ModernButtonStyle: ButtonStyle {
    var color: Color
    var isOutlined: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isOutlined ? Color.clear : color)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color, lineWidth: isOutlined ? 2 : 0)
            )
            .contentShape(RoundedRectangle(cornerRadius: 15))
            .foregroundColor(isOutlined ? color : .black)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .shadow(color: isOutlined ? .clear : color.opacity(0.3), radius: 10, y: 5)
            .animation(.spring(), value: configuration.isPressed)
    }
}
