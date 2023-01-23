import Foundation
// swiftlint:disable all
enum Configuration: String {
	// MARK: Possible configurations
	case staging
	case production

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
	static var baseChartsURL: URL {
		return URL(string: "https://music.yandex.by/handlers/playlist.jsx?owner=yamusic-missed&kinds=102979508")!
	}

	// MARK: Base URL for sharing songs
	static var baseURLForSharingSongs: String {
		return ""
	}
}
