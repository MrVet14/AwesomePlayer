import UIKit

class WelcomeViewController: UIViewController {
	private let signInButton: UIButton = {
		let button = UIButton()
		button.backgroundColor = UIColor(asset: Asset.spotifyGreen)
		button.setTitle(L10n.connectYourSpotifyAccount, for: .normal)
		return button
	}()

    override func viewDidLoad() {
        super.viewDidLoad()
		title = L10n.awesomePlayer

		view.backgroundColor = .systemGray

		view.addSubview(signInButton)
		signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
    }

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		signInButton.frame = CGRect(
			x: 20,
			y: view.height - 50 - view.safeAreaInsets.bottom,
			width: view.width - 40,
			height: 50
		)
	}

	@objc
	func didTapSignIn() {
		let authVC = AuthViewController()
		authVC.completionHandler = { [weak self] success in
			self?.handleSignIn(success: success)
		}
		authVC.navigationItem.largeTitleDisplayMode = .never
		navigationController?.pushViewController(authVC, animated: true)
	}

	private func handleSignIn(success: Bool) {
		guard success else {
			let alert = UIAlertController(title: L10n.somethingWentWrong, message: L10n.tryAgainLater, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: L10n.dismiss, style: .cancel))
			present(alert, animated: true)
			return
		}

		let mainVC = UINavigationController(rootViewController: MainViewController())
		mainVC.modalPresentationStyle = .fullScreen
		present(mainVC, animated: true)
	}
}
