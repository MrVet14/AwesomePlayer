import Foundation
import Moya

final class APICaller {
	static let shared = APICaller()

	let provider = MoyaProvider<SpotifyAPI>()

	// MARK: Max number is 100
	let numberOfRecommendedSongsToLoad = 100
	// MARK: Max number is 50
	let numberOfFeaturedPlaylistsToLoad = 20

	private init() {}

	// MARK: Loading a bunch of songs
	func loadSongs(
		_ ids: [String],
		completion: @escaping (Result<MultipleSongsResponse, Error>) -> Void
	) {
		provider.request(.loadSongs(ids: ids)) { result in
			switch result {
			case.success(let response):
				do {
					// for debugging only
					if 400...599 ~= response.statusCode {
						self.debugResponse("----- Error loading songs -----", response: response)
					}

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
					// for debugging only
					if 400...599 ~= response.statusCode {
						self.debugResponse("----- Error loading recommended songs -----", response: response)
					}

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
					// for debugging only
					if 400...599 ~= response.statusCode {
						self.debugResponse("----- Error loading user -----", response: response)
					}

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

	func loadRecommendedPlaylists(completion: @escaping (Result<FeaturedPlaylistsResponse, Error>) -> Void) {
		provider.request(.getFeaturedPlaylists) { result in
			switch result {
			case.success(let response):
				// for debugging only
				if 400...599 ~= response.statusCode {
					self.debugResponse("Failed to load Recommended Playlists", response: response)
				}

				do {
					let result = try JSONDecoder().decode(FeaturedPlaylistsResponse.self, from: response.data)
					completion(.success(result))
				} catch {
					self.printError("Failed to parse Recommended Playlists", error: error)
					completion(.failure(error))
				}

			case .failure(let error):
				self.printError("Failed to load Recommended Playlists", error: error)
				completion(.failure(error))
			}
		}
	}

	func loadPlaylistDetails(
		_ playlistID: String,
		completion: @escaping (Result<PlaylistDetailsResponse, Error>) -> Void
	) {
		provider.request(.getPlaylistDetails(id: playlistID)) { result in
			switch result {
			case .success(let response):
				// for debugging only
				if 400...599 ~= response.statusCode {
					self.debugResponse("Failed to load Playlist Details", response: response)
				}

				do {
					let result = try JSONDecoder().decode(PlaylistDetailsResponse.self, from: response.data)
					completion(.success(result))
				} catch {
					self.printError("Failed to parse Playlist Details", error: error)
					completion(.failure(error))
				}

			case .failure(let error):
				self.printError("Failed to load Playlist Details", error: error)
				completion(.failure(error))
			}
		}
	}

	// MARK: Printing out errors
	private func printError(
		_ msg: String,
		error: Error
	) {
		print(msg)
		print(error)
	}

	private func debugResponse(
		_ msq: String,
		response: Response
	) {
		print(msq)
		print("Status code: \(response.statusCode)")
		print("Request URL:", response.request as Any)
		print("Request Description:", response.description)
		print("Data:", String(bytes: response.data, encoding: .utf8) as Any)
	}
}

// MARK: Moya configuration
enum SpotifyAPI {
	case loadSongs(ids: [String]) // max 50 IDs
	case loadRecommended
	case loadUser
	case getFeaturedPlaylists
	case getPlaylistDetails(id: String)
}

extension SpotifyAPI: TargetType {
	var baseURL: URL {
		return Configuration.baseURL
	}

	var path: String {
		switch self {
		case .loadSongs:
			return "/tracks"

		case .loadRecommended:
			return "/recommendations"

		case .loadUser:
			return "/me"

		case .getFeaturedPlaylists:
			return "/browse/featured-playlists"

		case .getPlaylistDetails(let id):
			return "/playlists/\(id)"
		}
	}

	var method: Moya.Method {
		return .get
	}

	var task: Moya.Task {
		let encodingQueryString = URLEncoding.queryString

		switch self {
		case .loadSongs(ids: var ids):
			let apiLimit = APIConstants.loadSongsAPILimit

			// MARK: Checking if number of passed IDs is greater than 50
			if ids.count > apiLimit {
				if ids.count > (apiLimit * 2) {
					var newSetOfIDs: [String] = []
					for posInArr in 0..<apiLimit {
						newSetOfIDs.append(ids[posInArr])
					}
					ids = newSetOfIDs
				} else {
					while ids.count > apiLimit {
						ids.remove(at: apiLimit)
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
				"seed_genres": "pop,country,rock,alternative",
				"limit": "\(APICaller.shared.numberOfRecommendedSongsToLoad)"
			]
			return .requestParameters(parameters: parameters, encoding: encodingQueryString)

		case .loadUser:
			return .requestPlain

		case .getFeaturedPlaylists:
			let parameters = [
				"limit": "\(APICaller.shared.numberOfFeaturedPlaylistsToLoad)"
			]
			return .requestParameters(parameters: parameters, encoding: encodingQueryString)

		case .getPlaylistDetails:
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
