//
//  C4IHomeCards.swift
//  C4I
//

import SwiftUI

struct C4IMinistryCard: View {
    let card: C4IHomeCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: URL(string: card.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 252, height: 152)
            .clipped()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(card.title)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.primary)
                Text(card.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                Text("Learn More")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color("BrandPrimaryColor"))
                    .padding(.top, 2)
            }
            .padding(14)
        }
        .frame(width: 252, alignment: .topLeading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.10), radius: 8, x: 0, y: 4)
    }
}

struct C4IEpisodeCard: View {
    let episode: CollectionChild
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                if let cover = episode.cover, let url = URL(string: cover) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color("BrandPrimaryColor").opacity(0.18)
                    }
                } else {
                    LinearGradient(
                        colors: [Color("BrandPrimaryColor"), Color("BrandSecondaryColor")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                
                Image(systemName: "play.fill")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Circle())
            }
            .frame(width: 108, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Latest Episode")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Color("BrandPrimaryColor"))
                Text(episode.title)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                Text("Watch now")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.bold))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

struct C4IWatchFallbackCard: View {
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "play.rectangle.fill")
                .font(.largeTitle)
                .foregroundColor(Color("BrandPrimaryColor"))
            VStack(alignment: .leading, spacing: 6) {
                Text("Watch the Latest Episodes")
                    .font(.headline.weight(.semibold))
                Text("Open Israel: The Prophetic Connection")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct C4IActionTile: View {
    let action: C4IActionCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: action.systemImage)
                .font(.title2.weight(.semibold))
                .foregroundColor(action.isPrimary ? .white : Color("BrandPrimaryColor"))
            Text(action.title)
                .font(.headline.weight(.bold))
                .foregroundColor(action.isPrimary ? .white : .primary)
            Text(action.description)
                .font(.caption)
                .foregroundColor(action.isPrimary ? .white.opacity(0.82) : .secondary)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .padding(14)
        .background(action.isPrimary ? Color("BrandPrimaryColor") : Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
