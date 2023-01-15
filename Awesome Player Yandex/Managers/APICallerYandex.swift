import Foundation
import Moya
// swiftlint:disable all
class APICallerYandex {
	static let shared = APICallerYandex()

	//let provider = MoyaProvider<YandexAPI>()

	private init() {}

	// MARK: Printing out errors
	func printError(
		_ msg: String,
		error: Error
	) {
		print(msg)
		print(error.localizedDescription)
	}
}

// MARK: Moya configuration
enum YandexAPI {
}

//extension YandexAPI: TargetType {
//	var baseURL: URL {
//		<#code#>
//	}
//
//	var path: String {
//		<#code#>
//	}
//
//	var method: Moya.Method {
//		<#code#>
//	}
//
//	var task: Moya.Task {
//		<#code#>
//	}
//
//	var headers: [String : String]? {
//		<#code#>
//	}
//}

extension YandexAPI: AccessTokenAuthorizable {
	var authorizationType: Moya.AuthorizationType? {
		return .bearer
	}
}
