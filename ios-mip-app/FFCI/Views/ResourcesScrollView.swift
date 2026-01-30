//
//  ResourcesScrollView.swift
//  FFCI
//
//  Resources section with horizontal scrolling and card snapping
//

import SwiftUI

struct ResourcesScrollView: View {
    let quickTasks: [HomepageQuickTask]
    let onQuickTaskClick: (String) -> Void
    
    private let cardSpacing: CGFloat = 16
    private let horizontalPadding: CGFloat = 16
    private let peekAmount: CGFloat = 60 // Amount of next card visible for affordance
    private let baseCardWidth: CGFloat = 280 // Base width, will be adjusted for peek
    
    @State private var containerWidth: CGFloat = 0
    @State private var alignedIndex: Int? = nil
    
    private var cardWidth: CGFloat {
        guard containerWidth > 0 else { return baseCardWidth }
        // Calculate card width to ensure peek: when a card is fully visible, 
        // the next card should peek by peekAmount
        // Available width = containerWidth - (horizontalPadding * 2)
        // We want: cardWidth + peekAmount <= availableWidth
        let availableWidth = containerWidth - (horizontalPadding * 2)
        let maxCardWidth = availableWidth - peekAmount
        return min(baseCardWidth, max(240, maxCardWidth)) // Min 240pt for readability
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resources")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .accessibilityIdentifier("resources-section-title")
            
            GeometryReader { geo in
                ZStack(alignment: .trailing) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: cardSpacing) {
                            ForEach(Array(quickTasks.enumerated()), id: \.offset) { index, task in
                                Group {
                                    // Check externalUrl FIRST - external links should open in Safari
                                    // If we checked uuid first, items with BOTH uuid AND externalUrl
                                    // would incorrectly use NavigationLink instead of Link
                                    if let externalUrl = task.externalUrl, let url = URL(string: externalUrl) {
                                        Link(destination: url) {
                                            ResourcesCard(task: task, cardWidth: cardWidth)
                                        }
                                        .buttonStyle(.plain)
                                    } else if let uuid = task.uuid, !uuid.isEmpty {
                                        NavigationLink(destination: TabPageView(uuid: uuid)) {
                                            ResourcesCard(task: task, cardWidth: cardWidth)
                                        }
                                        .simultaneousGesture(TapGesture().onEnded {
                                            onQuickTaskClick(uuid)
                                        })
                                        .buttonStyle(.plain)
                                    } else {
                                        ResourcesCard(task: task, cardWidth: cardWidth)
                                    }
                                }
                                .accessibilityIdentifier("resources-card-\(index)")
                                .id(index)
                            }
                        }
                        .padding(.leading, horizontalPadding)
                        .padding(.trailing, horizontalPadding + peekAmount) // Extra trailing padding so last card can snap fully
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $alignedIndex)
                    .onAppear {
                        containerWidth = geo.size.width
                    }
                    .onChange(of: geo.size.width) { _, newValue in
                        containerWidth = newValue
                    }
                    
                    // Optional right-edge fade that disappears at the end
                    if let alignedIndex = alignedIndex, alignedIndex < quickTasks.count - 1, quickTasks.count > 1 {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color(red: 0.945, green: 0.961, blue: 0.976).opacity(0.8)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: 40)
                        .allowsHitTesting(false)
                    }
                }
            }
            .frame(height: 280) // Approximate height for cards
        }
        .padding(.vertical, 16)
        .background(Color(red: 0.945, green: 0.961, blue: 0.976))
    }
}
