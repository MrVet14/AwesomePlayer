import Foundation

enum KeyChainParameters {
	static let account: String = "AwesomePlayer"
}

// MARK: types of data that we can save to keychain
enum TypesOfDataForKeychain {
	static let accessToken = "accessToken"
	static let refreshToken = "refreshToken"
}

enum APIConstants {
	static let spotifyWebAPIBaseUrl = "spotifyWebAPIBaseUrl"
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
