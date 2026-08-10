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
    let profile: AppProfile
    let onQuickTaskClick: (String) -> Void
    let onFeaturedClick: (String) -> Void
    
    @State private var showSearch = false
    
    var body: some View {
        if let homeView = profile.homeView {
            homeView(siteMeta)
        } else {
            defaultHomeView
        }
    }
    
    private var defaultHomeView: some View {
        NavigationStack {
            VStack(spacing: 0) {
            ScrollView {
            VStack(spacing: 0) {
                
                // Header with logo and search button
                HomeHeaderView(siteMeta: siteMeta, logo: profile.headerLogo, onSearchTap: { showSearch = true })
                
                // Logo section - main homepage logo
                HomeLogoView(siteMeta: siteMeta)
                
                // Featured section
                if let featured = siteMeta.homepageFeatured, !featured.isEmpty {
                    FeaturedSectionView(featured: featured, onFeaturedClick: onFeaturedClick)
                }
                
                // Resources section
                if let quickTasks = siteMeta.homepageQuickTasks, !quickTasks.isEmpty {
                    ResourcesScrollView(
                        quickTasks: quickTasks,
                        onQuickTaskClick: onQuickTaskClick
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
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                }
            }
            }
            .background(Color(.systemBackground))
            }
        }
        .sheet(isPresented: $showSearch) {
            SearchView()
        }
        .onAppear {
            MipAnalytics.logContentView(
                pageUuid: MipAnalytics.homePageUuid,
                title: siteMeta.title,
                contentType: "home"
            )
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
        profile: .standard,
        onQuickTaskClick: { _ in },
        onFeaturedClick: { _ in }
    )
}
