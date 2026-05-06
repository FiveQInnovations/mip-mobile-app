//
//  AppProfile.swift
//  MIP Mobile App
//
//  Data-driven app customizations kept generic for shared UI.
//

import SwiftUI

struct AppProfile {
    let headerLogo: HeaderLogo
    let htmlContentTheme: HtmlContentTheme
    let homeView: ((SiteMeta) -> AnyView)?
    let tabs: (SiteData) -> [AppTab]
}

extension AppProfile {
    static let standard = AppProfile(
        headerLogo: .asset(name: "HeaderLogo", accessibilityLabel: "Firefighters for Christ Logo"),
        htmlContentTheme: .standard,
        homeView: nil,
        tabs: { siteData in
            var tabs = [
                AppTab(
                    id: 0,
                    title: "Home",
                    systemImage: "house.fill",
                    destination: .home,
                    screenName: "home",
                    screenClass: "HomeView"
                )
            ]

            let menuItems = siteData.menu.filter { $0.page.uuid != "__home__" }
            tabs += menuItems.enumerated().map { index, item in
                AppTab(
                    id: index + 1,
                    title: item.label,
                    systemImage: AppProfile.iconForTab(item.icon, index),
                    destination: item.tabDestination(linkSource: "menu_tab"),
                    screenName: "tab/\(item.page.uuid)",
                    screenClass: "TabPageView"
                )
            }

            return tabs
        }
    )

    private static func iconForTab(_ iconName: String?, _ index: Int) -> String {
        if let iconName = iconName?.lowercased() {
            switch iconName {
            case "home":
                return "house.fill"
            case "star":
                return "star.fill"
            case "book-outline", "book", "library-outline", "library":
                return "book.fill"
            case "people":
                return "person.2.fill"
            case "person":
                return "person.fill"
            case "information-circle-outline", "information-circle", "info":
                return "info.circle.fill"
            case "hand-left", "hand":
                return "hand.raised.fill"
            case "heart-outline", "heart":
                return "heart.fill"
            case "ellipse", "circle":
                return "circle.fill"
            case "menu-outline", "menu":
                return "line.3.horizontal"
            default:
                break
            }
        }

        switch index {
        case 0:
            return "book.fill"
        case 1:
            return "info.circle.fill"
        case 2:
            return "heart.fill"
        default:
            return "line.3.horizontal"
        }
    }
}

struct HtmlContentTheme: Equatable {
    let primaryHex: String
    let secondaryHex: String
    let primaryRgb: String
    let secondaryRgb: String
}

extension HtmlContentTheme {
    static let standard = HtmlContentTheme(
        primaryHex: "#D9232A",
        secondaryHex: "#024D91",
        primaryRgb: "217, 35, 42",
        secondaryRgb: "2, 77, 145"
    )
}

private struct HtmlContentThemeKey: EnvironmentKey {
    static let defaultValue = HtmlContentTheme.standard
}

extension EnvironmentValues {
    var htmlContentTheme: HtmlContentTheme {
        get { self[HtmlContentThemeKey.self] }
        set { self[HtmlContentThemeKey.self] = newValue }
    }
}

enum HeaderLogo {
    case asset(name: String, accessibilityLabel: String)
    case text(String, accessibilityLabel: String)
}

struct AppTab: Identifiable {
    let id: Int
    let title: String
    let systemImage: String
    let destination: AppTabDestination
    let screenName: String?
    let screenClass: String
}

enum AppTabDestination {
    case home
    case page(uuid: String)
    case external(url: URL, pageUuid: String, linkLabel: String, linkSource: String)
    case custom(AnyView)
}

extension MenuItem {
    func tabDestination(linkSource: String) -> AppTabDestination {
        if let externalUrl, let url = URL(string: externalUrl) {
            return .external(
                url: url,
                pageUuid: page.uuid,
                linkLabel: label,
                linkSource: linkSource
            )
        }

        return .page(uuid: page.uuid)
    }
}
