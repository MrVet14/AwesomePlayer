import Foundation

enum Configuration: String {
	// MARK: Possible configurations
	case staging
	case production
	case release

	// MARK: Current configuration
	static let current: Configuration = {
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
		switch current {
		case .staging:
			return URL(string: "https://api.spotify.com/v1")!
		case .production:
			return URL(string: "https://api.spotify.com/v1")!
		case .release:
			return URL(string: "https://api.spotify.com/v1")!
		}
	}

	// MARK: Spotify Client ID
	static var spotifyClientID: String {
		switch current {
		case .staging:
			return "a02da930b4a64ab8a976ea8376eda362"
		case .production:
			return "a02da930b4a64ab8a976ea8376eda362"
		case .release:
			return "a02da930b4a64ab8a976ea8376eda362"
		}
	}

	// MARK: Spotify Client Secret Key
	static var spotifyClientSecretKey: String {
		switch current {
		case .staging:
			return "dd4bc1311afa489b8c2e6f5ffe1298cf"
		case .production:
			return "dd4bc1311afa489b8c2e6f5ffe1298cf"
		case .release:
			return "dd4bc1311afa489b8c2e6f5ffe1298cf"
		}
	}

	// MARK: Redirect URI
	static var redirectURI: String {
		switch current {
		case .staging:
			return "https://scand.com"
		case .production:
			return "https://scand.com"
		case .release:
			return "https://scand.com"
		}
	}

	// MARK: Spotify API URI for Access Token
	static var spotifyAPITokenURL: URL {
		switch current {
		case .staging:
			return URL(string: "https://accounts.spotify.com/api/token")!
		case .production:
			return URL(string: "https://accounts.spotify.com/api/token")!
		case .release:
			return URL(string: "https://accounts.spotify.com/api/token")!
		}
	}

	// MARK: Spotify Auth Base URL
	static var spotifyAuthBaseURL: URL {
		switch current {
		case .staging:
			return URL(string: "https://accounts.spotify.com/authorize")!
		case .production:
			return URL(string: "https://accounts.spotify.com/authorize")!
		case .release:
			return URL(string: "https://accounts.spotify.com/authorize")!
		}
	}

	// MARK: Scopes for API Call
	static var APIScopes: String {
		switch current {
		case .staging:
			return "user-read-private user-read-email"
		case .production:
			return "user-read-private user-read-email"
		case .release:
			return "user-read-private user-read-email"
		}
	}

	// MARK: Base URL for sharing songs
	static var baseURLForSharingSongs: String {
		switch current {
		case .staging:
			return "https://open.spotify.com/track/"
		case .production:
			return "https://open.spotify.com/track/"
		case .release:
			return "https://open.spotify.com/track/"
		}
	}
}
