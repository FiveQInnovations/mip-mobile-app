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
        VStack(spacing: 0) {
            HStack {
                if C4IAppProfile.isCurrentSite {
                    Text(siteMeta.title)
                        .font(.title2.weight(.bold))
                        .foregroundColor(Color("BrandSecondaryColor"))
                        .accessibilityLabel("Christians for Israel Logo")
                } else {
                    Image("HeaderLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .accessibilityLabel("Firefighters for Christ Logo")
                }
                
                Spacer()
                
                // Search button on the right
                Button(action: onSearchTap) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("BrandPrimaryColor"))
                        .frame(width: 44, height: 44)
                }
                .accessibilityIdentifier("search-button")
                .accessibilityLabel("Search")
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 0)
        .padding(.bottom, 0)
        .background(Color.white)
    }
}
