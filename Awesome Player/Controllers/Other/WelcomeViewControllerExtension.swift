import SnapKit
import UIKit

extension WelcomeViewController {
	func setLogoImageAndButtonTitleColor() {
		logoImageView.image = UIImage(asset: Asset.appLogo)

		signInButton.backgroundColor = UIColor(asset: Asset.spotifyGreen)
		signInButton.setTitle(L10n.connectYourAccount("Spotify"), for: .normal)
	}

	@objc
	func didTapSignIn() {
		HapticsManager.shared.vibrateForSelection()
		let authVC = AuthViewController()
		authVC.completionHandler = { [weak self] success in
			self?.handleSignIn(success: success)
		}
		authVC.navigationItem.largeTitleDisplayMode = .never
		navigationController?.pushViewController(authVC, animated: true)
	}
}
