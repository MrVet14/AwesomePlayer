import Foundation

struct Song: Codable {
	let album: Album?
	let artists: [Artist]
	let explicit: Bool
	let id: String
	let name: String
	let preview_url: String?
}
