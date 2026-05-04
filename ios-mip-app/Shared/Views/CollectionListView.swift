//
//  CollectionListView.swift
//  FFCI
//
//  Collection list component for displaying page children
//

import SwiftUI

struct CollectionListView: View {
    let items: [CollectionChild]
    let onItemClick: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.uuid) { index, item in
                CollectionListItem(
                    item: item,
                    index: index,
                    onClick: { onItemClick(item.uuid) }
                )
                
                if index < items.count - 1 {
                    Divider()
                        .padding(.leading, 16)
                }
            }
        }
    }
}

struct CollectionListItem: View {
    let item: CollectionChild
    let index: Int
    let onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 12) {
                // Cover image (if available)
                if let cover = item.cover {
                    AsyncImage(url: URL(string: cover)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                // Title
                Text(item.title)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 16)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityIdentifier("collection-item-\(index)")
    }
}

#Preview {
    CollectionListView(
        items: [
            CollectionChild(uuid: "1", title: "Sample Item 1", cover: nil, type: nil),
            CollectionChild(uuid: "2", title: "Sample Item 2", cover: nil, type: nil)
        ],
        onItemClick: { uuid in
            print("Clicked: \(uuid)")
        }
    )
}
