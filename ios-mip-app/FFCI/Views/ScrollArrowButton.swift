//
//  ScrollArrowButton.swift
//  FFCI
//
//  Scroll arrow button component for horizontal scrolling
//

import SwiftUI

struct ScrollArrowButton: View {
    enum Direction {
        case left, right
        
        var iconName: String {
            self == .left ? "chevron.left" : "chevron.right"
        }
        
        var accessibilityId: String {
            self == .left ? "scroll-arrow-left" : "scroll-arrow-right"
        }
        
        var accessibilityText: String {
            self == .left ? "Scroll left" : "Scroll right"
        }
    }
    
    let direction: Direction
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: direction.iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.95))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(direction.accessibilityId)
        .accessibilityLabel(direction.accessibilityText)
    }
}
