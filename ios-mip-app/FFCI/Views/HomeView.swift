//
//  HomeView.swift
//  FFCI
//
//  Home screen with logo, featured content, and resources
//

import SwiftUI
import os.log

private let logger = Logger(subsystem: "com.fiveq.ffci", category: "HomeView")

struct HomeView: View {
    let siteMeta: SiteMeta
    let onQuickTaskClick: (String) -> Void
    let onFeaturedClick: (String) -> Void
    
    @State private var tapCount = 0
    @State private var showSearch = false
    @StateObject private var scrollTracker = ScrollTracker()
    
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
                HomeHeaderView(siteMeta: siteMeta, onSearchTap: { showSearch = true })
                
                // Featured section
                if let featured = siteMeta.homepageFeatured, !featured.isEmpty {
                    FeaturedSectionView(featured: featured, onFeaturedClick: onFeaturedClick)
                }
                
                // Resources section
                if let quickTasks = siteMeta.homepageQuickTasks, !quickTasks.isEmpty {
                    ResourcesScrollView(
                        quickTasks: quickTasks,
                        onQuickTaskClick: onQuickTaskClick,
                        scrollTracker: scrollTracker
                    )
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
