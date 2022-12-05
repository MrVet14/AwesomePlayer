import Foundation
import Moya

enum SpotifyAPI {
	case loadASong(id: String)
	case loadSongs(ids: [String]) // max 50 IDs
	case loadSongFeatures(id: String)
	case loadSongsFeatures(ids: [String]) // max 100 IDs
	case loadRecommended
}

extension SpotifyAPI: TargetType {
	var baseURL: URL {
		// swiftlint:disable force_cast
		return URL(string: Bundle.main.infoDictionary?[APIConstants.spotifyWebAPIBaseUrl] as! String)!
	}

	var path: String {
		switch self {
		case .loadASong(id: let id):
			return "/tracks/\(id)"

		case .loadSongs:
			return "/track"

		case .loadSongFeatures(id: let id):
			return "/audio-features/\(id)"

		case .loadSongsFeatures:
			return "/audio-features"

		case .loadRecommended:
			return "/recommendations"
		}
	}

	var method: Moya.Method {
		return .get
	}

	var task: Moya.Task {
		let encodingQueryString = URLEncoding.queryString

		switch self {
		case .loadASong:
			return .requestPlain

		case .loadSongs(ids: let ids):
			return .requestParameters(parameters: ["ids": ids], encoding: encodingQueryString)

		case .loadSongFeatures:
			return .requestPlain

		case .loadSongsFeatures(ids: let ids):
			return .requestParameters(parameters: ["ids": ids], encoding: encodingQueryString)

		case .loadRecommended:
			let parameters = [
				// Up to 5 seed values may be provided in any combination of seed_artists, seed_tracks and seed_genres
				// "seed_artists": "",
				"seed_genres": "pop,country",
				// "seed_tracks": "",
				"limit": "1"
			]
			return .requestParameters(parameters: parameters, encoding: encodingQueryString)
		}
	}

	var headers: [String: String]? {
		// MARK: getting access token from keychain
		let query: [String: Any] = [
			/// kSecAttrService,  kSecAttrAccount, and kSecClass uniquely identify the item in Keychain
			kSecAttrService as String: TypesOfDataForKeychain.accessToken as AnyObject,
			kSecAttrAccount as String: KeyChainParameters.account as AnyObject,
			kSecClass as String: kSecClassGenericPassword,
			kSecMatchLimit as String: kSecMatchLimitOne,
			kSecReturnData as String: kCFBooleanTrue!
		]

		/// SecItemCopyMatching will attempt to copy the item
		/// identified by query to the reference itemCopy
		var itemCopy: AnyObject?

		let status = SecItemCopyMatching(query as CFDictionary, &itemCopy)
		/// errSecItemNotFound is a special status indicating the
		/// read item does not exist. Throw itemNotFound so the
		/// client can determine whether or not to handle this case
		guard status != errSecItemNotFound else {
			print("Item not found")
			return nil
		}
		/// Any status other than errSecSuccess indicates the read operation failed.
		guard status == errSecSuccess else {
			print("Unexpected status: \(status)")
			return nil
		}
		/// checking if our value is indeed Data and it's present
		guard let dataToDecode = itemCopy as? Data else {
			print("InvalidItemFormat")
			return nil
		}

		let authToken = String(decoding: dataToDecode, as: UTF8.self)

		let headersToReturn = [
			"Content-type": "application/json",
			"Authorization": "Bearer \(authToken)"
		] as [String: String]

		return headersToReturn
	}
}

extension SpotifyAPI: AccessTokenAuthorizable {
	var authorizationType: Moya.AuthorizationType? {
		return .bearer
	}
}

class APICaller {
	let provider = MoyaProvider<SpotifyAPI>()

	func loadASong(_ id: String) {
		provider.request(.loadASong(id: id)) { result in
			self.testPrintResult(result)
		}
	}

	func loadSongs(_ ids: [String]) {
		provider.request(.loadSongs(ids: ids)) { result in
			self.testPrintResult(result)
		}
	}

	func loadSongFeatures(_ id: String) {
		provider.request(.loadSongFeatures(id: id)) { result in
			self.testPrintResult(result)
		}
	}

	func loadSongsFeatures(_ ids: [String]) {
		provider.request(.loadSongsFeatures(ids: ids)) { result in
			self.testPrintResult(result)
		}
	}

	func loadRecommendedTracks() {
		provider.request(.loadRecommended) { result in
			self.testPrintResult(result)
		}
	}

	func testPrintResult(_ result: Result<Moya.Response, Moya.MoyaError>) {
		switch result {
		case .success(let response):
			print("Success")
			print(response.statusCode)
			print(String(bytes: response.data, encoding: .utf8)!)
		case .failure(let error):
			print("Failure")
			print(error)
		}
	}
}
