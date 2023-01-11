import Foundation

struct AuthManagerSettingForAuth {
	let spotifyAuthBaseURL: URL
	let clientID: String
	let clientSecret: String
	let redirectURI: String
	let tokenAPIURL: URL
	let scopes: String
}
