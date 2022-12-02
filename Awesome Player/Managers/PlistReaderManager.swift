import Foundation

class PlistReaderManager {
	func returnString(_ key: String) -> String {
		guard let parameterToReturn = Bundle.main.infoDictionary?[key] as? String else {
			print("Error returning parameter")
			return ""
		}
		return parameterToReturn
	}

	func returnURL(_ key: String) -> URL {
		guard let URLStringToParse = Bundle.main.infoDictionary?[key] as? String else {
			print("Error returning URL")
			return URL(string: "")!
		}
		return URL(string: URLStringToParse)!
	}

	func returnStrings(_ keys: [String]) -> [String: String] {
		var parametersToReturn: [String: String] = [:]

		for key in keys {
			parametersToReturn[key] = returnString(key)
		}

		guard !parametersToReturn.isEmpty else {
			print("Error returning parameters")
			return [:]
		}

		return parametersToReturn
	}

	func returnURLs(_ keys: [String]) -> [String: URL] {
		var URLsToReturn: [String: URL] = [:]

		for key in keys {
			URLsToReturn[key] = returnURL(key)
		}

		guard !URLsToReturn.isEmpty else {
			print("Error returning URLs")
			return [:]
		}

		return URLsToReturn
	}
}
