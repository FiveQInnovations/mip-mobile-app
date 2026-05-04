//
//  SiteConfig.swift
//  MIP Mobile App
//
//  Per-site configuration loaded from a bundled SiteConfig.plist.
//  Each Xcode target includes its own plist so the same shared code
//  can run against different Kirby backends (FFCI, C4I, etc.).
//

import Foundation

struct SiteConfig {
    let siteBaseURL: URL
    let apiKey: String
    let basicAuthUsername: String
    let basicAuthPassword: String
    let authScheme: String
    let firstPartyHosts: [String]

    static let shared: SiteConfig = {
        guard let url = Bundle.main.url(forResource: "SiteConfig", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
            fatalError("SiteConfig.plist is missing or malformed")
        }

        guard let baseURLString = dict["SiteBaseURL"] as? String,
              let baseURL = URL(string: baseURLString) else {
            fatalError("SiteConfig.plist: SiteBaseURL is missing or invalid")
        }

        return SiteConfig(
            siteBaseURL: baseURL,
            apiKey: dict["ApiKey"] as? String ?? "",
            basicAuthUsername: dict["BasicAuthUsername"] as? String ?? "",
            basicAuthPassword: dict["BasicAuthPassword"] as? String ?? "",
            authScheme: dict["AuthScheme"] as? String ?? "site-auth",
            firstPartyHosts: dict["FirstPartyHosts"] as? [String] ?? []
        )
    }()

    var apiBaseURL: URL { siteBaseURL }

    func normalizedFirstPartyHost(_ host: String?) -> String? {
        guard let host else { return nil }
        let normalized = host.lowercased()
        for known in firstPartyHosts {
            let wwwVariant = "www.\(known)"
            if normalized == wwwVariant {
                return known
            }
        }
        return normalized
    }

    func isFirstPartyHost(_ host: String?) -> Bool {
        guard let normalized = normalizedFirstPartyHost(host) else { return false }
        return normalizedFirstPartyHost(siteBaseURL.host) == normalized
    }
}
