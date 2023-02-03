import Foundation
// swiftlint:disable all
class AuthManagerYandex {
	static let shared = AuthManagerYandex()

	private init() {}

	func createUser() -> User {
		User(
			country: "BY",
			display_name: "Vitali Vyucheiski",
			email: "vitali.vyucheiski@gmail.com",
			id: "23241337ABC",
			images: [Image(url: "https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=340451802970861&height=300&width=300&ext=1676619546&hash=AeRuE-9LiTD49eCw58Y")]
		)
	}
}
