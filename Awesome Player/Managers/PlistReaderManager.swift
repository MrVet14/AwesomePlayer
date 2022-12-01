//
//  LocalPlistReaderManager.swift
//  Awesome Player
//
//  Created by Vitali Vyucheiski on 11/17/22.
//

import Foundation

class PlistReaderManager {
	func returnString(_ key: String) -> String {
		guard let parameterToReturn = Bundle.main.infoDictionary?[key] as? String else {
			print("Error acquired")
			return ""
		}
		return parameterToReturn
	}

	func returnURL(_ key: String) -> URL {
		guard let URLStringToParse = Bundle.main.infoDictionary?[key] as? String else {
			print("Error acquired")
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
			print("Error acquired")
			return [:]
		}

		return parametersToReturn
	}
}
