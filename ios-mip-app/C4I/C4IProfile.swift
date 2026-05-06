//
//  C4IProfile.swift
//  C4I
//
//  C4i-specific app composition kept out of Shared.
//

import SwiftUI

enum C4IAppProfile {
    static let aboutUuid = "xhZj4ejQ65bRhrJg"
    static let ministriesUuid = "7gh4hdoRQgSIE7nI"
    static let learnUuid = "pik8ysClOFGyllBY"
    static let watchUuid = "Sw5g5dDFh35ZEEIc"
    static let getInvolvedUuid = "XoMTNzgSpFybWSiy"
    static let giveUrl = "https://c4i.fiveq.dev/get-involved/donate"
    static let storeUrl = "https://c4i.fiveq.dev/store"

    static let profile = AppProfile(
        headerLogo: .text("Christians for Israel", accessibilityLabel: "Christians for Israel Logo"),
        homeView: { siteMeta in
            AnyView(C4IHomeView(siteMeta: siteMeta))
        },
        tabs: { _ in
            [
                AppTab(
                    id: 0,
                    title: "Home",
                    systemImage: "house.fill",
                    destination: .home,
                    screenName: "home",
                    screenClass: "HomeView"
                ),
                AppTab(
                    id: 1,
                    title: "Ministries",
                    systemImage: "heart.fill",
                    destination: .page(uuid: ministriesUuid),
                    screenName: "tab/\(ministriesUuid)",
                    screenClass: "TabPageView"
                ),
                AppTab(
                    id: 2,
                    title: "Watch",
                    systemImage: "play.rectangle.fill",
                    destination: .page(uuid: watchUuid),
                    screenName: "tab/\(watchUuid)",
                    screenClass: "TabPageView"
                ),
                AppTab(
                    id: 3,
                    title: "Give",
                    systemImage: "gift.fill",
                    destination: .external(
                        url: URL(string: giveUrl)!,
                        pageUuid: MipAnalytics.homePageUuid,
                        linkLabel: "Give",
                        linkSource: "menu_tab"
                    ),
                    screenName: nil,
                    screenClass: "MainTabView"
                ),
                AppTab(
                    id: 4,
                    title: "More",
                    systemImage: "line.3.horizontal",
                    destination: .custom(AnyView(C4IMoreView(sections: moreSections))),
                    screenName: "more",
                    screenClass: "MainTabView"
                )
            ]
        }
    )

    static let moreSections: [C4IMoreSection] = [
        C4IMoreSection(title: "About", items: [
            C4IMoreItem(title: "About Us", systemImage: "info.circle", destination: .page(aboutUuid)),
            C4IMoreItem(title: "Our Story", systemImage: "book.closed", destination: .page("NT9a3MjdDUYuVOiS")),
            C4IMoreItem(title: "Leadership & Team", systemImage: "person.2", destination: .page("WjlIls52GzZvsk7t")),
            C4IMoreItem(title: "Contact", systemImage: "envelope", destination: .page("1eWnsUo0JF08lKMf"))
        ]),
        C4IMoreSection(title: "Learn", items: [
            C4IMoreItem(title: "Learn", systemImage: "graduationcap", destination: .page(learnUuid)),
            C4IMoreItem(title: "Audio", systemImage: "waveform", destination: .page("8zgomEX4mEIWyoiM")),
            C4IMoreItem(title: "Podcast", systemImage: "mic", destination: .page("aYf517xwvTitm6LH")),
            C4IMoreItem(title: "Prayer Map", systemImage: "map", destination: .page("y7s7fMXdoIlSqQJl"))
        ]),
        C4IMoreSection(title: "Get Involved", items: [
            C4IMoreItem(title: "Get Involved", systemImage: "hands.sparkles", destination: .page(getInvolvedUuid)),
            C4IMoreItem(title: "Donate", systemImage: "gift", destination: .external(giveUrl)),
            C4IMoreItem(title: "Pray", systemImage: "heart", destination: .page("Mvk1aXwec0DS2emw")),
            C4IMoreItem(title: "Volunteer", systemImage: "figure.2", destination: .page("aVDlKV98mUiHbwX3")),
            C4IMoreItem(title: "Book a Speaker", systemImage: "person.wave.2", destination: .page("SkJVxSJe1fSeZtjK"))
        ]),
        C4IMoreSection(title: "Links", items: [
            C4IMoreItem(title: "Store", systemImage: "bag", destination: .external(storeUrl))
        ])
    ]
}

struct C4IMoreSection: Identifiable {
    var id: String { title }
    let title: String
    let items: [C4IMoreItem]
}

struct C4IMoreItem: Identifiable {
    var id: String { "\(title)-\(destination.id)" }
    let title: String
    let systemImage: String
    let destination: C4IDestination
}

enum C4IDestination {
    case page(String)
    case external(String)

    var id: String {
        switch self {
        case .page(let uuid):
            return "page-\(uuid)"
        case .external(let url):
            return "external-\(url)"
        }
    }
}
