//
//  HomeHeaderView.swift
//  FFCI
//
//  Header section with logo and search button
//

import SwiftUI

struct HomeHeaderView: View {
    let siteMeta: SiteMeta
    let onSearchTap: () -> Void
    
    var body: some View {
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
                    Button(action: onSearchTap) {
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
    }
}
