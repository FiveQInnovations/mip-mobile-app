//
//  HomeView.swift
//  FFCI
//
//  Home screen with logo, featured content, and resources
//

import SwiftUI

struct HomeView: View {
    let siteMeta: SiteMeta
    let onQuickTaskClick: (String) -> Void
    let onFeaturedClick: (String) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header with logo
                VStack(spacing: 8) {
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
                            FeaturedCard(
                                featured: item,
                                onClick: {
                                    if let uuid = item.uuid {
                                        onFeaturedClick(uuid)
                                    }
                                }
                            )
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
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(quickTasks, id: \.uuid) { task in
                                    ResourcesCard(
                                        task: task,
                                        onClick: {
                                            if let uuid = task.uuid {
                                                onQuickTaskClick(uuid)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
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

struct FeaturedCard: View {
    let featured: HomepageFeatured
    let onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
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
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ResourcesCard: View {
    let task: HomepageQuickTask
    let onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
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
        }
        .buttonStyle(PlainButtonStyle())
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
