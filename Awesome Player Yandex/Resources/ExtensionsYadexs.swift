import Foundation

extension String {
	var lowercaseFirstLetter: String {
		let firstLetter = self.prefix(1).lowercased()
		let remainingLetters = self.dropFirst()
		return firstLetter + remainingLetters
	}
}
