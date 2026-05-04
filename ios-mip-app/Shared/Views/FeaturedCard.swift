//
//  FeaturedCard.swift
//  FFCI
//
//  Card component for featured content items
//

import SwiftUI

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
