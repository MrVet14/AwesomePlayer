import Foundation
import UIKit

class HapticsManager {
	static let shared = HapticsManager()

	private init() {}

	let selectorGenerator = UISelectionFeedbackGenerator()
	let feedbackGenerator = UINotificationFeedbackGenerator()

	// MARK: Vibrating on selection
	func vibrateForSelection() {
		DispatchQueue.main.async {
			self.selectorGenerator.selectionChanged()
		}
	}

	// MARK: Vibrating on some feedback
	func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
		DispatchQueue.main.async {
			self.feedbackGenerator.notificationOccurred(type)
		}
	}
}
