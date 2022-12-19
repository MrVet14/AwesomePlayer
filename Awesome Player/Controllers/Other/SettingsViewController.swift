import UIKit

class SettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

		setupViews()
    }

	func setupViews() {
		title = L10n.settings
		view.backgroundColor = .systemPink
	}
}
