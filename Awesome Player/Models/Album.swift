import Foundation

struct Album: Codable {
	let id: String
	var images: [Image]
	let name: String
	let artists: [Artist]
}
