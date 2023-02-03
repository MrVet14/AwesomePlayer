import Foundation

struct SongYandex: Codable {
	let albums: [AlbumYandex?]
	let artists: [ArtistYandex?]
	let realId: String
	let title: String
	let storageDir: String
	let coverUri: String
}
