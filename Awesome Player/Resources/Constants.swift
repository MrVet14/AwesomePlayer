import Foundation

enum KeyChainParameters {
	static let account: String = "AwesomePlayer"
}

// MARK: types of data that we can save to keychain
enum TypesOfDataForKeychain {
	static let accessToken = "accessToken"
	static let refreshToken = "refreshToken"
}

enum PlistBundleParameters {
	static let spotifyAuthBaseURL: String = "spotifyAuthBaseURL"
	static let spotifyClientId: String = "spotifyClientId"
	static let spotifyClientSecretKey: String = "spotifyClientSecretKey"
	static let redirectUri: String = "redirectUri"
	static let spotifyAPITokenURL: String = "spotifyAPITokenURL"
	static let scopes: String = "scopes"
}

enum APIConstants {
	static let spotifyWebAPIBaseUrl = "spotifyWebAPIBaseUrl"
	static let baseURLForSharingSongs = "https://open.spotify.com/track/"
	static let loadSongsAPILimit = 50
}

enum KeychainError: Error {
	/// Attempted read for an item that does not exist.
	case itemNotFound
	/// Attempted save to override an existing item.
	/// Use update instead of save to update existing items
	case duplicateItem
	/// A read of an item in any format other than Data
	case invalidItemFormat
	/// Any operation result status than errSecSuccess
	case unexpectedStatus(OSStatus)
}

enum DBSongTypes {
	static let liked = "liked"
	static let recommended = "recommended"
	static let inAPlaylist = "inAPlaylist"
}

enum NotificationCenterConstants {
	static let playerVCClosed = "playerVCClosed"
	static let playerBar = "playerBar"
}
