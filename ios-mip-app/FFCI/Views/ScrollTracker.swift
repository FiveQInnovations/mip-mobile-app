//
//  ScrollTracker.swift
//  FFCI
//
//  Scroll position tracking state and calculations
//

import SwiftUI

class ScrollTracker: ObservableObject {
    @Published var scrollOffset: CGFloat = 0
    @Published var contentWidth: CGFloat = 0
    @Published var containerWidth: CGFloat = 0
    @Published var visibleIndex: Int = 0
    
    private let cardWidth: CGFloat = 280
    private let cardSpacing: CGFloat = 16
    
    var canScrollLeft: Bool {
        scrollOffset > 5
    }
    
    var canScrollRight: Bool {
        scrollOffset < (contentWidth - containerWidth - 5)
    }
    
    func calculateVisibleIndex() -> Int {
        let itemWidth = cardWidth + cardSpacing
        return max(0, Int((scrollOffset + itemWidth / 2) / itemWidth))
    }
    
    func updateScrollOffset(_ value: CGFloat) {
        scrollOffset = value
        visibleIndex = calculateVisibleIndex()
    }
}
