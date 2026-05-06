//
//  C4IHomeContent.swift
//  C4I
//

import Foundation

enum C4IHomeContent {
    static let ministries = [
        C4IHomeCard(
            title: "Children at Risk",
            description: "Protecting and nurturing the most vulnerable through faith-based initiatives.",
            imageUrl: "https://c4i-5q.b-cdn.net/image/pexels-pixabay-163768.jpg?crop=1666,1333,334,0&width=700",
            uuid: "wOBbyxzzXbjT51nP"
        ),
        C4IHomeCard(
            title: "Feed the Hungry",
            description: "Providing meals and food security for struggling families across Canada and abroad.",
            imageUrl: "https://c4i-5q.b-cdn.net/image/feeding.jpg?crop=1665,1333,130,0&width=700",
            uuid: "JtjXwwg9lCuFe4ui"
        ),
        C4IHomeCard(
            title: "Humanitarian Aid",
            description: "Supporting the Jewish people through practical aid and spiritual encouragement.",
            imageUrl: "https://c4i-5q.b-cdn.net/image/aid-2.jpg?crop=1665,1333,168,0&width=700",
            uuid: "TMxzmwCuXBvjODle"
        ),
        C4IHomeCard(
            title: "New Immigrants",
            description: "Helping new arrivals integrate through care, mentoring, and basic needs.",
            imageUrl: "https://c4i-5q.b-cdn.net/image/pexels-liza-summer-6383158.jpg?crop=1665,1333,105,0&width=700",
            uuid: "i0bIgOyuNnBwnyRY"
        )
    ]

    static let actions = [
        C4IActionCard(title: "Donate", description: "Give critical resources where they are needed most.", systemImage: "gift.fill", destination: .external(C4IAppProfile.giveUrl), isPrimary: true),
        C4IActionCard(title: "Volunteer", description: "Join practical work that blesses Israel and local communities.", systemImage: "person.2.fill", destination: .page("aVDlKV98mUiHbwX3"), isPrimary: false),
        C4IActionCard(title: "Shop", description: "Visit the C4I store for ministry resources.", systemImage: "bag.fill", destination: .external(C4IAppProfile.storeUrl), isPrimary: false),
        C4IActionCard(title: "Pray", description: "Stand with Israel through focused prayer resources.", systemImage: "heart.fill", destination: .page("Mvk1aXwec0DS2emw"), isPrimary: false),
        C4IActionCard(title: "Book a Speaker", description: "Invite a Bible-grounded speaker for your church or event.", systemImage: "person.wave.2.fill", destination: .page("SkJVxSJe1fSeZtjK"), isPrimary: false)
    ]
}

struct C4IHomeCard: Identifiable {
    var id: String { uuid }
    let title: String
    let description: String
    let imageUrl: String
    let uuid: String
}

struct C4IActionCard: Identifiable {
    var id: String { "\(title)-\(destination.id)" }
    let title: String
    let description: String
    let systemImage: String
    let destination: C4IDestination
    let isPrimary: Bool
}
