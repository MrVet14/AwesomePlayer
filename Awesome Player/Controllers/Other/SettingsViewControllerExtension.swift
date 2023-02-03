import Foundation
import UIKit

extension SettingsViewController {
	func signOut() {
		let alert = UIAlertController(title: L10n.signOut, message: L10n.areYouSure, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: L10n.signOut, style: .destructive, handler: { _ in
			AuthManager.shared.signOut { [weak self] _ in
				let welcomeVC = UINavigationController(rootViewController: WelcomeViewController())
				welcomeVC.modalPresentationStyle = .fullScreen
				self?.present(welcomeVC, animated: true, completion: {
					self?.navigationController?.popToRootViewController(animated: false)
				})
			}
		}))
		present(alert, animated: true)
	}
}
