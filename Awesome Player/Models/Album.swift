import Foundation

struct Album: Codable {
	let id: String
	let images: [Image]
	let name: String
	let artists: [Artist]
}
