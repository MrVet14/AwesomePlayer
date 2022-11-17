//
//  LocalPlistReaderManager.swift
//  Awesome Player
//
//  Created by Vitali Vyucheiski on 11/17/22.
//

import Foundation

class LocalPlistReaderManager {
	func getPlist() -> [String: Any]? {
		var infoPlist: [String: Any]?

		if let infoPlistPath = Bundle.main.url(
			forResource: "Info",
			withExtension: "plist"
		) {
			do {
				let infoPlistData = try Data(contentsOf: infoPlistPath)
				if let dict = try PropertyListSerialization.propertyList(
					from: infoPlistData,
					options: [],
					format: nil
				) as? [String: Any] {
					infoPlist = dict
				}
			} catch {
				print(error)
			}
		}

		return infoPlist
	}

	func returnString(_ forKey: String) -> String {
		let infoPlist = getPlist()

		guard let returnSting = infoPlist?[forKey] as? String else {
			return "Error occurred"
		}

		return returnSting
	}

	func returnURL(_ forKey: String) -> URL {
		let infoPlist = getPlist()

		guard let returnURL = URL(string: infoPlist?[forKey] as? String ?? "") else {
			return URL(string: "")!
		}

		return returnURL
	}
}
