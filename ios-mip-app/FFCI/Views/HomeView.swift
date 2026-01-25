//
//  HomeView.swift
//  FFCI
//
//  Home screen with logo, featured content, and resources
//

import SwiftUI
import os.log

private let logger = Logger(subsystem: "com.fiveq.ffci", category: "HomeView")

// PreferenceKey for tracking scroll offset
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// PreferenceKey for tracking content width
struct ContentWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct HomeView: View {
    let siteMeta: SiteMeta
    let onQuickTaskClick: (String) -> Void
    let onFeaturedClick: (String) -> Void
    
    @State private var tapCount = 0
    @State private var showSearch = false
    
    // Scroll arrow state
    @State private var scrollOffset: CGFloat = 0
    @State private var contentWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @State private var visibleIndex: Int = 0
    
    private var canScrollLeft: Bool {
        scrollOffset > 5
    }
    
    private var canScrollRight: Bool {
        scrollOffset < (contentWidth - containerWidth - 5)
    }
    
    private let cardWidth: CGFloat = 280
    private let cardSpacing: CGFloat = 16
    
    private func calculateVisibleIndex() -> Int {
        let itemWidth = cardWidth + cardSpacing
        return max(0, Int((scrollOffset + itemWidth / 2) / itemWidth))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // DEBUG: Test button to verify taps work
                // This button is used for Maestro UI testing to verify tap functionality
                // Placed outside ScrollView to ensure it's always accessible
                Button(action: {
                    tapCount += 1
                    logger.notice("TEST TAP: count = \(tapCount)")
                }) {
                    Text("TAP TEST: \(tapCount)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityIdentifier("tap-test-button")
                .accessibilityLabel("TAP TEST: \(tapCount)")
                .accessibilityValue("\(tapCount)")
                .padding()
                .buttonStyle(.plain)
            
            ScrollView {
            VStack(spacing: 0) {
                
                // Header with logo and search button
                VStack(spacing: 8) {
                    ZStack {
                        if let logo = siteMeta.logo {
                            let logoUrl = logo.starts(with: "http://") || logo.starts(with: "https://") 
                                ? logo 
                                : "https://ffci.fiveq.dev\(logo)"
                            
                            AsyncImage(url: URL(string: logoUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(height: 80)
                        } else {
                            Text(siteMeta.title)
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        
                        HStack {
                            Spacer()
                            Button(action: { showSearch = true }) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color("PrimaryColor"))
                                    .frame(width: 44, height: 44)
                            }
                            .accessibilityIdentifier("search-button")
                            .accessibilityLabel("Search")
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white)
                
                // Featured section
                if let featured = siteMeta.homepageFeatured, !featured.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Featured")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 16)
                            .padding(.top, 24)
                        
                        ForEach(featured, id: \.uuid) { item in
                            Group {
                                if let uuid = item.uuid, !uuid.isEmpty {
                                    NavigationLink(destination: TabPageView(uuid: uuid)) {
                                        FeaturedCard(featured: item)
                                    }
                                    .simultaneousGesture(TapGesture().onEnded {
                                        onFeaturedClick(uuid)
                                    })
                                    .buttonStyle(.plain)
                                } else if let externalUrl = item.externalUrl, let url = URL(string: externalUrl) {
                                    Link(destination: url) {
                                        FeaturedCard(featured: item)
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    FeaturedCard(featured: item)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 6)
                        }
                    }
                }
                
                // Resources section
                if let quickTasks = siteMeta.homepageQuickTasks, !quickTasks.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Resources")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 16)
                            .padding(.top, 24)
                        
                        // ZStack for scroll arrows overlay
                        ScrollViewReader { scrollProxy in
                            ZStack {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: cardSpacing) {
                                        ForEach(Array(quickTasks.enumerated()), id: \.element.uuid) { index, task in
                                            Group {
                                                if let uuid = task.uuid, !uuid.isEmpty {
                                                    NavigationLink(destination: TabPageView(uuid: uuid)) {
                                                        ResourcesCard(task: task)
                                                    }
                                                    .simultaneousGesture(TapGesture().onEnded {
                                                        onQuickTaskClick(uuid)
                                                    })
                                                    .buttonStyle(.plain)
                                                } else if let externalUrl = task.externalUrl, let url = URL(string: externalUrl) {
                                                    Link(destination: url) {
                                                        ResourcesCard(task: task)
                                                    }
                                                    .buttonStyle(.plain)
                                                } else {
                                                    ResourcesCard(task: task)
                                                }
                                            }
                                            .id(index)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .background(
                                        GeometryReader { geo in
                                            Color.clear
                                                .preference(key: ContentWidthPreferenceKey.self, value: geo.size.width)
                                                .preference(key: ScrollOffsetPreferenceKey.self, value: -geo.frame(in: .named("resourcesScroll")).minX)
                                        }
                                    )
                                }
                                .coordinateSpace(name: "resourcesScroll")
                                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                                    scrollOffset = value
                                    visibleIndex = calculateVisibleIndex()
                                }
                                .onPreferenceChange(ContentWidthPreferenceKey.self) { value in
                                    contentWidth = value
                                }
                                .background(
                                    GeometryReader { geo in
                                        Color.clear.onAppear {
                                            containerWidth = geo.size.width
                                        }
                                    }
                                )
                                
                                // Left scroll arrow
                                if canScrollLeft {
                                    HStack {
                                        ScrollArrowButton(direction: .left) {
                                            let targetIndex = max(0, visibleIndex - 1)
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                scrollProxy.scrollTo(targetIndex, anchor: .leading)
                                            }
                                        }
                                        .padding(.leading, 8)
                                        Spacer()
                                    }
                                }
                                
                                // Right scroll arrow
                                if canScrollRight {
                                    HStack {
                                        Spacer()
                                        ScrollArrowButton(direction: .right) {
                                            let targetIndex = min(quickTasks.count - 1, visibleIndex + 1)
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                scrollProxy.scrollTo(targetIndex, anchor: .leading)
                                            }
                                        }
                                        .padding(.trailing, 8)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .background(Color(red: 0.945, green: 0.961, blue: 0.976))
                }
                
                // Welcome message if no content
                if (siteMeta.homepageQuickTasks?.isEmpty ?? true) && (siteMeta.homepageFeatured?.isEmpty ?? true) {
                    VStack(spacing: 16) {
                        Text("Welcome to")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Text(siteMeta.title)
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Explore resources and content using the tabs below.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(32)
                }
            }
            }
            .background(Color(.systemBackground))
            }
        }
        .sheet(isPresented: $showSearch) {
            SearchView()
        }
    }
}

struct FeaturedCard: View {
    let featured: HomepageFeatured
    
    var body: some View {
        if let imageUrl = featured.imageUrl {
            // Card with image
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Content overlay
                VStack(alignment: .leading, spacing: 8) {
                    if let badge = featured.badgeText {
                        Text(badge.uppercased())
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .cornerRadius(4)
                    }
                    
                    if let title = featured.title {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    if let description = featured.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(2)
                    }
                }
                .padding(16)
            }
            .contentShape(Rectangle())
        } else {
            // Simple card without image
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let title = featured.title {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    if let description = featured.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if let badge = featured.badgeText {
                    Text(badge.uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .cornerRadius(4)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            .contentShape(Rectangle())
        }
    }
}

struct ResourcesCard: View {
    let task: HomepageQuickTask
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let imageUrl = task.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(height: 158)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let label = task.label {
                    Text(label)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }
                
                if let description = task.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(16)
        }
        .frame(width: 280)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .contentShape(Rectangle())
    }
}

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

#Preview {
    HomeView(
        siteMeta: SiteMeta(
            title: "FFCI",
            social: nil,
            logo: nil,
            homepageQuickTasks: nil,
            homepageFeatured: nil
        ),
        onQuickTaskClick: { _ in },
        onFeaturedClick: { _ in }
    )
}
