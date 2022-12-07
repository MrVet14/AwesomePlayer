import Foundation

struct Playlist: Codable {
	let description: String
	let external_urls: [String: String]
	let id: String
	let images: [Image]
	let name: String
}
