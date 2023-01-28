import Foundation
import Moya

class APICallerYandex {
	static let shared = APICallerYandex()

	let provider = MoyaProvider<YandexAPI>()

	private init() {}

	func loadChart(completion: @escaping (Result<SeveralSongsResponse, Error>) -> Void) {
		provider.request(.loadRecommended) { result in
			switch result {
			case .success(let response):
				let data = response.data
				do {
//					let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
					let result = try JSONDecoder().decode(SeveralSongsResponse.self, from: data)
					completion(.success(result))
				} catch {
					print(String(data: data, encoding: .utf8) as Any)
					self.printError("Failed to parse songs", error: error)
					completion(.failure(error))
				}

			case .failure(let error):
				self.printError("Failed to load songs", error: error)
				completion(.failure(error))
			}
		}
	}

	func makeFirstCallToAPI(
		songID: String,
		albumID: String,
		completion: @escaping (Result<FirstAPIStorageResponse, Error>) -> Void
	) {
		provider.request(.firstAPIStorageResponse(songID: songID, albumID: albumID)) { result in
			switch result {
			case .success(let response):
				let data = response.data
				do {
//					let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
//					print(json)
					let result = try JSONDecoder().decode(FirstAPIStorageResponse.self, from: data)
					completion(.success(result))
				} catch {
					print(String(data: data, encoding: .utf8) as Any)
					self.printError("Failed to parse first request", error: error)
					completion(.failure(error))
				}

			case .failure(let error):
				self.printError("Failed to load first request for a song", error: error)
				completion(.failure(error))
			}
		}
	}

	func makeSecondCallToAPI(
		src: String,
		completion: @escaping (Result<URL, Error>) -> Void
	) {
		provider.request(.secondAPIStorageResponse(src: src)) { result in
			switch result {
			case .success(let response):
				let data = response.data
				do {
//					let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
//					print(json)
					let result = try JSONDecoder().decode(SecondAPIStorageResponse.self, from: data)

					let link = result.host + "/get-mp3/" + "????" + "/\(result.ts)" + result.path
					let url = URL(string: "https://\(link)")!

					completion(.success(url))
				} catch {
					print(String(data: data, encoding: .utf8) as Any)
					self.printError("Failed to parse final request", error: error)
					completion(.failure(error))
				}

			case .failure(let error):
				self.printError("Failed to load final request for a song", error: error)
				completion(.failure(error))
			}
		}
	}

	// MARK: Printing out errors
	func printError(
		_ msg: String,
		error: Error
	) {
		print(msg)
		print(error)
	}
}

// MARK: Moya configuration
enum YandexAPI {
	case loadRecommended
	case firstAPIStorageResponse(songID: String, albumID: String)
	case secondAPIStorageResponse(src: String)
}

extension YandexAPI: TargetType {
	var baseURL: URL {
		switch self {
		case .loadRecommended:
			return Configuration.baseChartsURL

		case .firstAPIStorageResponse:
			return Configuration.gettingSongsBaseURL

		case .secondAPIStorageResponse(let src):
			let link = src + "&format=json"
			return URL(string: "https:\(link)")!
		}
	}

	var path: String {
		switch self {
		case .loadRecommended, .secondAPIStorageResponse:
			return ""

		case .firstAPIStorageResponse(let songID, let albumID):
			return "\(songID):\(albumID)/web-user_playlists-playlist-track-main/download/m"
		}
	}

	var method: Moya.Method {
		switch self {
		case .loadRecommended, .firstAPIStorageResponse, .secondAPIStorageResponse:
			return .get
		}
	}

	var task: Moya.Task {
		switch self {
		case .loadRecommended, .firstAPIStorageResponse, .secondAPIStorageResponse:
			return .requestPlain
		}
	}

	var headers: [String: String]? {
		switch self {
		case .loadRecommended, .secondAPIStorageResponse:
			return .none

		case .firstAPIStorageResponse:
			// Mock data
			return ["X-Retpath-Y": "https%3A%2F%2Fmusic.yandex.ru%2Fusers%2Fmusic-blog%2Fplaylists%2F2441"]
		}
	}
}

extension YandexAPI: AccessTokenAuthorizable {
	var authorizationType: Moya.AuthorizationType? {
		return .bearer
	}
}
