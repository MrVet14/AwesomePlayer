import SnapKit
import UIKit

class WelcomeViewController: UIViewController {
	let waysToSayHi = [
		"Hello", "Привет", "你好", "今日は", " 안녕하세요", "Bonjour", "Hola",
		"Hallo", "Ciao", "Ahoy!", "Aloha", "नमस्ते", "γεια σας", "Salve", "Osiyo"
	]

	var timer: Timer?

	// MARK: - Subviews
	let signInButton: UIButton = {
		let button = UIButton()
		button.backgroundColor = UIColor(asset: Asset.spotifyGreen)
		button.setTitle(L10n.connectYourSpotifyAccount, for: .normal)
		button.titleLabel?.font = .boldSystemFont(ofSize: 20)
		return button
	}()

	let backGroundImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(asset: Asset.welcomeScreenBG)
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()

	let overlayView: UIView = {
		let view = UIView()
		view.backgroundColor = .black
		view.alpha = 0.7
		return view
	}()

	let logoImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(asset: Asset.appLogo)
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()

	let mottoLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		label.textAlignment = .center
		label.textColor = .white
		label.font = .systemFont(ofSize: 30, weight: .semibold)
		label.text = L10n.awesomeMusicPlayerInTouchWithTomorrow
		return label
	}()

	let greetingsLabel: UILabel = {
		let label = UILabel()
		label.textColor = .white
		label.textAlignment = .center
		label.font = .systemFont(ofSize: 36, weight: .bold)
		label.text = L10n.awesomePlayer
		return label
	}()

	// MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
		self.timer = Timer.scheduledTimer(
			timeInterval: 3.0,
			target: self,
			selector: #selector(changeTitle),
			userInfo: nil,
			repeats: true
		)

		setupViews()

		signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
    }

	// MARK: Adding view elements to View & configuring them
	func setupViews() {
		view.backgroundColor = .black
		view.addSubview(backGroundImageView)
		view.addSubview(overlayView)
		view.addSubview(greetingsLabel)
		view.addSubview(logoImageView)
		view.addSubview(mottoLabel)
		view.addSubview(signInButton)
	}

	// MARK: Setting Constraints
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		backGroundImageView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		overlayView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		greetingsLabel.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalTo(170)
		}

		logoImageView.snp.makeConstraints { make in
			make.size.equalTo(220)
			make.top.equalTo(greetingsLabel.snp.bottom).offset(50)
			make.centerX.equalToSuperview()
		}

		mottoLabel.snp.makeConstraints { make in
			make.top.equalTo(logoImageView.snp.bottom).offset(40)
			make.leading.equalToSuperview().offset(50)
			make.trailing.equalToSuperview().offset(-50)
		}

		signInButton.snp.makeConstraints { make in
			make.height.equalTo(70)
			make.leading.equalToSuperview().offset(20)
			make.trailing.equalToSuperview().offset(-20)
			make.bottom.equalToSuperview().offset(-30)
		}
	}

	// MARK: Controller logic
	@objc
	func changeTitle() {
		greetingsLabel.fadeTransition(0.6)
		greetingsLabel.text = waysToSayHi.randomElement()
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

		timer?.invalidate()
		let mainVC = TabBarViewController()
		mainVC.modalPresentationStyle = .fullScreen
		present(mainVC, animated: true)
	}
}
