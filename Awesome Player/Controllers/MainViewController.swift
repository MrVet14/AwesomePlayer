import SnapKit
import UIKit

class MainViewController: UIViewController {
    // MARK: - Subviews
    private lazy var connectLabel: UILabel = {
        let label = UILabel()
		label.text = L10n.welcome
        label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
		label.textColor = UIColor(asset: Asset.spotifyGreen)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    // MARK: Methods
    func setupViews() {
		view.backgroundColor = .systemBackground

        view.addSubview(connectLabel)

        connectLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        connectLabel.bottomAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
