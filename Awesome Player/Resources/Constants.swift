import Foundation

enum KeyChainParameters {
	internal static let account: String = "AwesomePlayer"
}

// MARK: types of data that we can save to keychain
enum TypesOfDataForKeychain {
	internal static let accessToken = "accessToken"
	internal static let refreshToken = "refreshToken"
}

enum PlistBundleParameters {
	internal static let spotifyAuthBaseURL: String = "spotifyAuthBaseURL"
	internal static let spotifyClientId: String = "spotifyClientId"
	internal static let spotifyClientSecretKey: String = "spotifyClientSecretKey"
	internal static let redirectUri: String = "redirectUri"
	internal static let spotifyAPITokenURL: String = "spotifyAPITokenURL"
	internal static let scopes: String = "scopes"
}

enum APIConstants {
	internal static let spotifyWebAPIBaseUrl = "spotifyWebAPIBaseUrl"
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
	internal static let liked = "liked"
	internal static let recommended = "recommended"
	internal static let inAPlaylist = "inAPlaylist"
}
