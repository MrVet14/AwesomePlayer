import Foundation

struct Artist: Codable {
	let id: String
	let name: String
	let type: String
	let images: [Image]?
}
