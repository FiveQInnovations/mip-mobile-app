//
//  ApiModels.swift
//  FFCI
//
//  Firefighters for Christ International - API Data Models
//

import Foundation

// MARK: - Menu Models

struct MenuPage: Codable {
    let uuid: String
    let type: String
    let url: String
}

struct MenuItem: Codable {
    let label: String
    let icon: String?
    let page: MenuPage
}

// MARK: - Site Meta Models

struct HomepageQuickTask: Codable {
    let uuid: String?
    let label: String?
    let description: String?
    let imageUrl: String?
    let externalUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case label
        case description
        case imageUrl = "image_url"
        case externalUrl = "external_url"
    }
}

struct HomepageFeatured: Codable {
    let uuid: String?
    let title: String?
    let description: String?
    let imageUrl: String?
    let badgeText: String?
    let externalUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case title
        case description
        case imageUrl = "image_url"
        case badgeText = "badge_text"
        case externalUrl = "external_url"
    }
}

struct SocialLink: Codable {
    let platform: String
    let url: String
}

struct SiteMeta: Codable {
    let title: String
    let social: [SocialLink]?
    let logo: String?
    let homepageQuickTasks: [HomepageQuickTask]?
    let homepageFeatured: [HomepageFeatured]?
    
    enum CodingKeys: String, CodingKey {
        case title
        case social
        case logo
        case homepageQuickTasks = "homepage_quick_tasks"
        case homepageFeatured = "homepage_featured"
    }
}

struct SiteData: Codable {
    let menu: [MenuItem]
    let siteData: SiteMeta
    
    enum CodingKeys: String, CodingKey {
        case menu
        case siteData = "site_data"
    }
}

// MARK: - Page Models

struct AudioData: Codable {
    let audioUrl: String?
    let audioName: String?
    let audioCredit: String?
    
    enum CodingKeys: String, CodingKey {
        case audioUrl = "audio_url"
        case audioName = "audio_name"
        case audioCredit = "audio_credit"
    }
}

struct PageDataContent: Codable {
    let pageContent: String?
    let audio: AudioData?
    let audioUrl: String?
    let audioName: String?
    let audioCredit: String?
    
    enum CodingKeys: String, CodingKey {
        case pageContent = "page_content"
        case audio
        case audioUrl = "audio_url"
        case audioName = "audio_name"
        case audioCredit = "audio_credit"
    }
}

struct CollectionChild: Codable {
    let uuid: String
    let title: String
    let cover: String?
    let type: String?
}

struct PageData: Codable {
    let pageType: String?
    let type: String?
    let title: String
    let cover: String?
    let pageContent: String?
    let children: [CollectionChild]?
    let data: PageDataContent?
    let hasForm: Bool?
    
    enum CodingKeys: String, CodingKey {
        case pageType = "page_type"
        case type
        case title
        case cover
        case pageContent = "page_content"
        case children
        case data
        case hasForm = "has_form"
    }
    
    // Helper to get effective page type
    var effectivePageType: String {
        return pageType ?? type ?? "content"
    }
    
    // Helper to check if this is an audio item
    var isAudioItem: Bool {
        return effectivePageType == "collection-item" && type == "audio"
    }
    
    // Helper to get audio URL from various locations
    var audioUrl: String? {
        return data?.audio?.audioUrl ?? data?.audioUrl
    }
    
    // Helper to get audio title
    var audioTitle: String? {
        return data?.audio?.audioName ?? data?.audioName ?? title
    }
    
    // Helper to get audio artist/credit
    var audioArtist: String? {
        return data?.audio?.audioCredit ?? data?.audioCredit
    }
    
    // Helper to get HTML content
    var htmlContent: String? {
        switch effectivePageType {
        case "content":
            return pageContent
        case "collection-item":
            return data?.pageContent
        default:
            return nil
        }
    }
}

// MARK: - Search Models

struct SearchResult: Codable {
    let uuid: String
    let title: String
    let description: String?
    let url: String
}
