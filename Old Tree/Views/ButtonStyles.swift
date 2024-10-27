//
//  ButtonStyles.swift
//  Old Tree
//
//  Created by Jens Aga Malm on 27/10/2024.
//
import SwiftUI

enum ButtonStyles {
    struct Scale: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
        }
    }
    
    struct Circle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
        }
    }
}
