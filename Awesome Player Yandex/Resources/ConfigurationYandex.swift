import Foundation

enum Configuration: String {
	// MARK: Possible configurations
	case staging
	case production

	// MARK: Current configuration
	private static let current: Self = {
		guard let rawValue = Bundle.main.infoDictionary?["Configuration"] as? String else {
			fatalError("No Configuration Found")
		}

		guard let configuration = Self(rawValue: rawValue.lowercased()) else {
			fatalError("Invalid Configuration")
		}

		return configuration
	}()

	// MARK: Base URL for Yandex
	static var baseChartsURL: URL {
		return URL(string: "https://music.yandex.by/handlers/playlist.jsx?owner=yamusic-dejavu&kinds=37361060")!
	}

	// MARK: Base URL for getting song from Yandex
	static var gettingSongsBaseURL: URL {
		return URL(string: "https://music.yandex.ru/api/v2.1/handlers/track/")!
	}

	// MARK: Base URL for sharing songs
	static var baseURLForSharingSongs: String {
		return ""
	}
}
