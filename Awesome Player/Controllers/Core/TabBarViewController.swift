import UIKit

class TabBarViewController: UITabBarController {
	let playerBar: UIView = PlayerBarAboveAllViewsView.shared
	var gesture = UITapGestureRecognizer()

	// MARK: App lifecycle + TabBarController Set Up
    override func viewDidLoad() {
        super.viewDidLoad()

		// Adding VCs to Tab Bar and configuring Tab Bar Behavior & UI
		let mainVC = MainViewController()
		let likedSongsVC = LikedSongsViewController()

		mainVC.title = setTitleDependingOnTheTimeOfDay()
		likedSongsVC.title = L10n.likedSongs

		mainVC.navigationItem.largeTitleDisplayMode = .always
		likedSongsVC.navigationItem.largeTitleDisplayMode = .always

		let nav1 = UINavigationController(rootViewController: mainVC)
		let nav2 = UINavigationController(rootViewController: likedSongsVC)

		nav1.tabBarItem = UITabBarItem(title: L10n.explore, image: UIImage(systemName: "music.note.list"), tag: 1)
		nav2.tabBarItem = UITabBarItem(title: L10n.likedSongs, image: UIImage(systemName: "heart.fill"), tag: 1)

		nav1.navigationBar.prefersLargeTitles = true
		nav2.navigationBar.prefersLargeTitles = true

		setViewControllers([nav1, nav2], animated: false)

		// Managing Player Bar
		playerBar.isHidden = true
		view.addSubview(playerBar)

		// Laying out constraints for Player Bar
		playerBar.snp.makeConstraints { make in
			make.height.equalTo(60)
			make.leading.equalToSuperview().offset(7)
			make.trailing.equalToSuperview().offset(-7)
			make.bottom.equalToSuperview().offset(-87)
		}

		// Catching notification from presenter
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(showPlayerBar),
			name: Notification.Name(NotificationCenterConstants.playerBar),
			object: nil
		)

		// Adding tap gesture to Player Bar
		gesture = UITapGestureRecognizer(target: self, action: #selector(presentPlayerVC))
		playerBar.addGestureRecognizer(gesture)
    }

	// MARK: Setting View Title depending on the time of the day
	func setTitleDependingOnTheTimeOfDay() -> String {
		let hour = Calendar.current.component(.hour, from: Date())

		switch hour {
		case 6..<12:
			return L10n.goodMorning
		case 12..<17:
			return L10n.goodAfternoon
		case 17..<22:
			return L10n.goodEvening
		default:
			return L10n.goodNight
		}
	}

	// MARK: Making Player Bar visible ofter notification from presenter
	@objc
	func showPlayerBar() {
		playerBar.isHidden = false
	}

	// MARK: Presenting PlayerVC after tapping Player bar
	@objc
	func presentPlayerVC() {
		let playerVC = PlayerViewController.shared
		present(playerVC, animated: true)
	}
}
