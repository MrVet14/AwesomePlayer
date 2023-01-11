import Foundation

class AuthManagerVariablesParser {
	static let shared = AuthManagerVariablesParser()

	func parse() -> AuthManagerSettingForAuth {
		AuthManagerSettingForAuth(
			spotifyAuthBaseURL: Configuration.spotifyAuthBaseURL,
			clientID: Configuration.spotifyClientID,
			clientSecret: Configuration.spotifyClientSecretKey,
			redirectURI: Configuration.redirectURI,
			tokenAPIURL: Configuration.spotifyAPITokenURL,
			scopes: Configuration.APIScopes.replacingOccurrences(of: " ", with: "%20")
		)
	}
}
