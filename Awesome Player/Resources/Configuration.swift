import Foundation

enum Configuration: String {
	// MARK: Possible configurations
	case staging
	case production
	case release

	// MARK: Current configuration
	private static let current: Configuration = {
		guard let rawValue = Bundle.main.infoDictionary?["Configuration"] as? String else {
			fatalError("No Configuration Found")
		}

		guard let configuration = Configuration(rawValue: rawValue.lowercased()) else {
			fatalError("Invalid Configuration")
		}

		return configuration
	}()

	// MARK: Base URL for Spotify API
	static var baseURL: URL {
			return URL(string: "https://api.spotify.com/v1")!
	}

	// MARK: Spotify Client ID
	private static var spotifyClientID: String {
			return "a02da930b4a64ab8a976ea8376eda362"
	}

	// MARK: Spotify Client Secret Key
	private static var spotifyClientSecretKey: String {
			return "dd4bc1311afa489b8c2e6f5ffe1298cf"
	}

	// MARK: Redirect URI
	private static var redirectURI: String {
			return "https://scand.com"
	}

	// MARK: Spotify API URI for Access Token
	private static var spotifyAPITokenURL: URL {
			return URL(string: "https://accounts.spotify.com/api/token")!
	}

	// MARK: Spotify Auth Base URL
	private static var spotifyAuthBaseURL: URL {
			return URL(string: "https://accounts.spotify.com/authorize")!
	}

	// MARK: Scopes for API Call
	private static var APIScopes: String {
			return "user-read-private user-read-email"
	}

	// MARK: Base URL for sharing songs
	static var baseURLForSharingSongs: String {
		return "https://open.spotify.com/track/"
	}

	// MARK: Creating variable that we pass to AuthManager
	static let passedVarsToAuthManager = AuthManagerSettingForAuth(
		spotifyAuthBaseURL: spotifyAuthBaseURL,
		clientID: spotifyClientID,
		clientSecret: spotifyClientSecretKey,
		redirectURI: redirectURI,
		tokenAPIURL: spotifyAPITokenURL,
		scopes: APIScopes.replacingOccurrences(of: " ", with: "%20")
	)
}
