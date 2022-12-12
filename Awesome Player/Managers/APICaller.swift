import Foundation
import Moya

class APICaller {
	static let shared = APICaller()

	let provider = MoyaProvider<SpotifyAPI>()

	private init() {}

	// MARK: Loading a song
	func loadASong(
		_ id: String,
		completion: @escaping (Result<Song, Error>) -> Void
	) {
		provider.request(.loadASong(id: id)) { result in
			switch result {
			case.success(let response):
				do {
					let result = try JSONDecoder().decode(Song.self, from: response.data)
					completion(.success(result))
				} catch {
					self.printError("Failed to parse a song", error: error)
					completion(.failure(error))
				}

			case .failure(let error):
				self.printError("Failed to load a song", error: error)
				completion(.failure(error))
			}
		}
	}

	// MARK: Loading a bunch of songs
	func loadSongs(
		_ ids: [String],
		completion: @escaping (Result<MultipleSongsResponse, Error>) -> Void
	) {
		provider.request(.loadSongs(ids: ids)) { result in
			switch result {
			case.success(let response):
				do {
					let result = try JSONDecoder().decode(MultipleSongsResponse.self, from: response.data)
					completion(.success(result))
				} catch {
					self.printError("Failed to parse songs", error: error)
					completion(.failure(error))
				}

			case .failure(let error):
				self.printError("Failed to load songs", error: error)
				completion(.failure(error))
			}
		}
	}

	// MARK: Loading recommended tracks
	func loadRecommendedTracks(completion: @escaping (Result<MultipleSongsResponse, Error>) -> Void) {
		provider.request(.loadRecommended) { result in
			switch result {
			case.success(let response):
				do {
					let result = try JSONDecoder().decode(MultipleSongsResponse.self, from: response.data)
					completion(.success(result))
				} catch {
					self.printError("Failed to parse recommended Tracks", error: error)
					completion(.failure(error))
				}

			case .failure(let error):
				self.printError("Failed to load recommended Tracks", error: error)
				completion(.failure(error))
			}
		}
	}

	// MARK: Loading user profile
	func loadUser(completion: @escaping (Result<User, Error>) -> Void) {
		provider.request(.loadUser) { result in
			switch result {
			case.success(let response):
				do {
					let result = try JSONDecoder().decode(User.self, from: response.data)
					completion(.success(result))
				} catch {
					self.printError("Failed to parse User Info", error: error)
					completion(.failure(error))
				}

			case .failure(let error):
				self.printError("Failed to load User Info", error: error)
				completion(.failure(error))
			}
		}
	}

	// MARK: Printing out errors
	func printError(_ msg: String, error: Error) {
		print(msg)
		print(error.localizedDescription)
	}
}

// MARK: Moya configuration

enum SpotifyAPI {
	case loadASong(id: String)
	case loadSongs(ids: [String]) // max 50 IDs
	case loadRecommended
	case loadUser
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
			return "/tracks"

		case .loadRecommended:
			return "/recommendations"

		case .loadUser:
			return"/me"
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

		case .loadSongs(ids: var ids):
			// MARK: Checking if number of passed IDs is greater than 50
			if ids.count > 50 {
				if ids.count > 100 {
					var newSetOfIDs: [String] = []
					for posInArr in 0..<50 {
						newSetOfIDs.append(ids[posInArr])
					}
					ids = newSetOfIDs
				} else {
					while ids.count > 50 {
						ids.remove(at: 50)
					}
				}
				print("""
						You must not pass more than 50 ids at once, due to Spotify WEB API limitations
						All the IDs past 50 have been removed
				""")
			}

			// MARK: Joining array of string with "," separator to pass as String parameter
			let idsToReturn = ids.joined(separator: ",")
			return .requestParameters(parameters: ["ids": idsToReturn], encoding: encodingQueryString)

		case .loadRecommended:
			let parameters = [
				// Up to 5 seed values may be provided in any combination of seed_artists, seed_tracks and seed_genres
				// "seed_artists": "",
				"seed_genres": "pop,country",
				// "seed_tracks": "",
				"limit": "25"
			]
			return .requestParameters(parameters: parameters, encoding: encodingQueryString)

		case .loadUser:
			return .requestPlain
		}
	}

	var headers: [String: String]? {
		var authToken: String = ""

		AuthManager.shared.validToken { token in
			authToken = token
		}

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
