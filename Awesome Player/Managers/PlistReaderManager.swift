//
//  LocalPlistReaderManager.swift
//  Awesome Player
//
//  Created by Vitali Vyucheiski on 11/17/22.
//

import Foundation

class PlistReaderManager {
	func returnString(_ key: String) -> String {
		guard let parametreToReturn = Bundle.main.infoDictionary?[key] as? String else {
			print("Error acquired")
			return ""
		}
		return parametreToReturn
	}

	func returnURL(_ key: String) -> URL {
		guard let URLStringToParse = Bundle.main.infoDictionary?[key] as? String else {
			print("Error acquired")
			return URL(string: "")!
		}
		return URL(string: URLStringToParse)!
	}
}
