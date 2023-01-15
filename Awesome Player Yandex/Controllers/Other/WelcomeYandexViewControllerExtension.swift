import SnapKit
import UIKit

extension WelcomeViewController {
	@objc
	func didTapSignIn() {
		HapticsManager.shared.vibrateForSelection()
//		let authVC = AuthViewController()
//		authVC.completionHandler = { [weak self] success in
//			self?.handleSignIn(success: success)
//		}
//		authVC.navigationItem.largeTitleDisplayMode = .never
//		navigationController?.pushViewController(authVC, animated: true)
	}
}
