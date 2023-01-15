import SnapKit
import UIKit

extension WelcomeViewController {
	func setLogoImageAndButtonTitleColor() {
		logoImageView.image = UIImage(asset: Asset.appLogoYandex)

		signInButton.backgroundColor = UIColor(asset: Asset.yandexRed)
		signInButton.setTitle(L10n.connectYourYandexAccount, for: .normal)
	}

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
