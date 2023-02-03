import Foundation

struct User: Codable {
	let country: String
	let display_name: String
	let email: String
	let id: String
	let images: [Image]
}
