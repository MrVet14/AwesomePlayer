import Foundation
import Moya
// swiftlint:disable all
class APICallerYandex {
	static let shared = APICallerYandex()

	let provider = MoyaProvider<YandexAPI>()

	private init() {}

	func loadChart(completion: @escaping (Result<SeveralSongsResponse, Error>) -> Void) {
		provider.request(.loadRecommended) { result in
			switch result {
			case .success(let response):
				do {
					//let json = try JSONSerialization.jsonObject(with: response.data, options: .fragmentsAllowed)
					let result = try JSONDecoder().decode(SeveralSongsResponse.self, from: response.data)
					completion(.success(result))
				} catch {
					print(String(data: response.data, encoding: .utf8) as Any)
					self.printError("Failed to parse songs", error: error)
					completion(.failure(error))
				}

			case .failure(let error):
				self.printError("Failed to load songs", error: error)
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
}

extension YandexAPI: TargetType {
	var baseURL: URL {
		return Configuration.baseChartsURL
	}

	var path: String {
		return ""
	}

	var method: Moya.Method {
		.get
	}

	var task: Moya.Task {
		.requestPlain
	}

	var headers: [String : String]? {
		.none
	}
}

extension YandexAPI: AccessTokenAuthorizable {
	var authorizationType: Moya.AuthorizationType? {
		return .bearer
	}
}
