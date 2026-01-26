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
    
    var maxScrollOffset: CGFloat {
        max(contentWidth - containerWidth, 0)
    }
    
    var canScrollLeft: Bool {
        // Check both offset and visibleIndex to handle edge cases where
        // scroll tracking may report slightly non-zero offset at start position
        scrollOffset > 5 && visibleIndex > 0
    }
    
    var canScrollRight: Bool {
        scrollOffset < (maxScrollOffset - 5)
    }
    
    func calculateVisibleIndex() -> Int {
        let itemWidth = cardWidth + cardSpacing
        return max(0, Int((scrollOffset + itemWidth / 2) / itemWidth))
    }
    
    func updateScrollOffset(_ value: CGFloat) {
        let clampedOffset = min(max(value, 0), maxScrollOffset)
        scrollOffset = clampedOffset
        visibleIndex = calculateVisibleIndex()
    }
}
