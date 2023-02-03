import SnapKit
import UIKit

extension WelcomeViewController {
	func setLogoImageAndButtonTitleColor() {
		logoImageView.image = UIImage(asset: Asset.appLogoYandex)

		signInButton.backgroundColor = UIColor(asset: Asset.yandexRed)
		signInButton.setTitle(L10n.connectYourAccount(SupportedPlatforms.yandex), for: .normal)
	}

	@objc func didTapSignIn() {
		HapticsManager.shared.vibrateForSelection()
		let mainVC = TabBarViewController()
		mainVC.modalPresentationStyle = .fullScreen
		self.present(mainVC, animated: true, completion: {
			self.navigationController?.popToRootViewController(animated: false)
		})
	}
}
