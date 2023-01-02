import UIKit

class TabBarViewController: UITabBarController {
	// MARK: App lifecycle + TabBarController Set Up
    override func viewDidLoad() {
        super.viewDidLoad()

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
}
