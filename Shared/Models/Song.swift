import Foundation

struct Song: Codable {
	let album: Album?
	let artists: [Artist]
	let explicit: Bool
	let id: String
	let name: String
	let preview_url: String?

	var artistName: String {
		switch artists.count {
		case 1:
			return artists[0].name
		case 2:
			return "\(artists[0].name) & \(artists[1].name)"
		default:
			return L10n.numerousArtists
		}
	}
}
