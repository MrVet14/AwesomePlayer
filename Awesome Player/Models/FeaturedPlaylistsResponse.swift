import Foundation

struct FeaturedPlaylistsResponse: Codable {
	let playlists: PlaylistResponse
}

struct PlaylistResponse: Codable {
	let items: [Playlist]
}
