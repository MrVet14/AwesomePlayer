import Foundation

struct SeveralSongsResponse: Codable {
	let playlist: SongsShell
}

struct SongsShell: Codable {
	let tracks: [SongYandex]
}
