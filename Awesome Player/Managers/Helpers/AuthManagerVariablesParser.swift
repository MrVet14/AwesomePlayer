import Foundation

class AuthManagerVariablesParser {
	static let shared = AuthManagerVariablesParser()

	func parse() -> AuthManagerSettingForAuth {
		// swiftlint:disable force_cast
		var varsToReturn = AuthManagerSettingForAuth(
			spotifyAuthBaseURL: Bundle.main.infoDictionary?[PlistBundleParameters.spotifyAuthBaseURL] as! String,
			clientID: Bundle.main.infoDictionary?[PlistBundleParameters.spotifyClientId] as! String,
			clientSecret: Bundle.main.infoDictionary?[PlistBundleParameters.spotifyClientSecretKey] as! String,
			redirectURI: Bundle.main.infoDictionary?[PlistBundleParameters.redirectUri] as! String,
			tokenAPIURL: Bundle.main.infoDictionary?[PlistBundleParameters.spotifyAPITokenURL] as! String,
			scopes: (Bundle.main.infoDictionary?[PlistBundleParameters.scopes] as! String)
		)

		varsToReturn.scopes = varsToReturn.scopes.replacingOccurrences(of: " ", with: "%20")
		return varsToReturn
	}
}
