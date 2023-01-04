import Foundation
import UIKit

class HapticsManager {
	static let shared = HapticsManager()

	private init() {}

	// MARK: Vibrating on selection
	func vibrateForSelection() {
		DispatchQueue.main.async {
			let generator = UISelectionFeedbackGenerator()
			generator.prepare()
			generator.selectionChanged()
		}
	}

	// MARK: Vibrating on some feedback
	func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
		DispatchQueue.main.async {
			let generator = UINotificationFeedbackGenerator()
			generator.prepare()
			generator.notificationOccurred(type)
		}
	}
}
