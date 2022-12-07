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
					print("Failed to parse a song")
					print("Error: \(error.localizedDescription)")
					completion(.failure(error))
				}

			case .failure(let error):
				print("Failed to load a song")
				print("Error: \(error.localizedDescription)")
				completion(.failure(error))
			}
		}
	}

	// MARK: Loading a bunch of songs
	func loadSongs(
		_ ids: String,
		completion: @escaping (Result<MultipleSongsResponse, Error>) -> Void
	) {
		provider.request(.loadSongs(ids: ids)) { result in
			switch result {
			case.success(let response):
				do {
					let result = try JSONDecoder().decode(MultipleSongsResponse.self, from: response.data)
					completion(.success(result))
				} catch {
					print("Failed to parse songs")
					print("Error: \(error.localizedDescription)")
					completion(.failure(error))
				}

			case .failure(let error):
				print("Failed to load songs")
				print("Error: \(error.localizedDescription)")
				completion(.failure(error))
			}
		}
	}

	// MARK: Loading recommended tracks
	func loadRecommendedTracks(completion: @escaping (Result<RecommendationsResponse, Error>) -> Void) {
		provider.request(.loadRecommended) { result in
			switch result {
			case.success(let response):
				do {
					let result = try JSONDecoder().decode(RecommendationsResponse.self, from: response.data)
					completion(.success(result))
				} catch {
					print("Failed to parse recommended Tracks")
					print("Error: \(error.localizedDescription)")
					completion(.failure(error))
				}

			case .failure(let error):
				print("Failed to load recommended Tracks")
				print("Error: \(error.localizedDescription)")
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
					print("Failed to parse User Info")
					print("Error: \(error.localizedDescription)")
					completion(.failure(error))
				}

			case .failure(let error):
				print("Failed to load User Info")
				print("Error: \(error.localizedDescription)")
				completion(.failure(error))
			}
		}
	}
}

// MARK: Moya configuration

enum SpotifyAPI {
	case loadASong(id: String)
	case loadSongs(ids: String) // max 50 IDs
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

		case .loadSongs(ids: let ids):
			return .requestParameters(parameters: ["ids": ids], encoding: encodingQueryString)

		case .loadRecommended:
			let parameters = [
				// Up to 5 seed values may be provided in any combination of seed_artists, seed_tracks and seed_genres
				// "seed_artists": "",
				"seed_genres": "pop,country",
				// "seed_tracks": "",
				"limit": "10"
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
