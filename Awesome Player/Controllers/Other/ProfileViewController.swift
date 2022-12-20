import UIKit
// swiftlint:disable all
class ProfileViewController: UIViewController {
	var userProfile: UserObject?

    override func viewDidLoad() {
        super.viewDidLoad()
		loadData()
		setupViews()
    }

	func setupViews() {
		title = L10n.profile
		view.backgroundColor = .systemMint
	}

	// MARK: Loading data for the controller
	func loadData() {
		DBManager.shared.getUserFromDB { [weak self] result in
			self?.userProfile = result
		}
	}
}
