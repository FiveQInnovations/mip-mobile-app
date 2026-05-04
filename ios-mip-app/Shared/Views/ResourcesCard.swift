//
//  ResourcesCard.swift
//  FFCI
//
//  Card component for resources/quick tasks
//

import SwiftUI

struct ResourcesCard: View {
    let task: HomepageQuickTask
    let cardWidth: CGFloat
    
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
        .frame(width: cardWidth)
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
