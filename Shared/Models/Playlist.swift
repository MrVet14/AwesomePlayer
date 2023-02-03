import Foundation

struct Playlist: Codable {
	let description: String
	let id: String
	let images: [Image]
	let name: String
	let tracks: PlaylistTotalTracks
}

struct PlaylistTotalTracks: Codable {
	let total: Int
}
