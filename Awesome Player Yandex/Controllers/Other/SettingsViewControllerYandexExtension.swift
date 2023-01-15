import Foundation
import UIKit

extension SettingsViewController {
	func signOut() {
		let alert = UIAlertController(title: L10n.signOut, message: L10n.areYouSure, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: L10n.signOut, style: .destructive, handler: { _ in
			// Sign out logic
		}))
		present(alert, animated: true)
	}
}
