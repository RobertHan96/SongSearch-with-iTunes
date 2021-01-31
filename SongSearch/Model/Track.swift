import UIKit

struct Response: Codable {
    let resultCount: Int
    let results: [Track]
}

struct Track: Codable {
    let title: String
    let artistName: String
    let thumbnail: String
    let previewUrl: String
    
    enum CodingKeys: String, CodingKey {
        case title = "trackName"
        case artistName = "artistName"
        case thumbnail = "artworkUrl100"
        case previewUrl = "previewUrl"
    }
}
