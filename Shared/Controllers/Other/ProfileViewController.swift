import Kingfisher
import SnapKit
import UIKit

final class ProfileViewController: UIViewController {
	var userProfile: UserObject?

	var model: [String] = []

	// MARK: - Subviews
	let tableView: UITableView = {
		let tableView = UITableView()
		tableView.isHidden = true
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		return tableView
	}()

	// MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

		setupViews()
		loadData()

		tableView.dataSource = self
		tableView.delegate = self
    }

	// MARK: Adding view elements to View & configuring them
	func setupViews() {
		title = L10n.profile
		view.backgroundColor = .systemBackground

		view.addSubview(tableView)
	}

	// MARK: Loading data for the controller
	func loadData() {
		DBManager.shared.getUserFromDB { [weak self] result in
			self?.userProfile = result
			if let model = self?.userProfile {
				self?.updateView(with: model)
			}
		}
	}

	// MARK: Adding view elements to View & configuring them
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		tableView.frame = view.bounds
	}

	// MARK: Updating View with recent data
	func updateView(with model: UserObject) {
		if userProfile == nil {
			failedToGetUser()
		}

		self.model.append("\(L10n.fullName): \(model.displayName)")
		self.model.append("\(L10n.emailAddress): \(model.email)")
		self.model.append("\(L10n.userID): \(model.id)")
		self.model.append("\(L10n.country): \(model.country)")
		createTableHeader(with: model.imageURL)

		tableView.isHidden = false
		tableView.reloadData()
	}

	// MARK: Showing label wit error in case one occurred
	func failedToGetUser() {
		let label = UILabel(frame: .zero)
		label.text = L10n.failedToLoadUserData
		label.sizeToFit()
		label.textColor = .secondaryLabel

		view.addSubview(label)
		label.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
	}
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
	// MARK: TableView set up
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return model.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = model[indexPath.row]
		cell.selectionStyle = .none
		return cell
	}

	func createTableHeader(with string: String) {
		guard let url = URL(string: string) else {
			return
		}

		let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.width / 1.5))

		let imageSize: CGFloat = headerView.height / 1.5
		let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))

		headerView.addSubview(imageView)
		imageView.center = headerView.center
		imageView.contentMode = .scaleAspectFit
		imageView.kf.setImage(
			with: url,
			placeholder: UIImage(asset: Asset.anonymousUserJpg),
			options: [.transition(.fade(0.5))]
		)
		imageView.layer.masksToBounds = true
		imageView.layer.cornerRadius = imageSize / 2

		tableView.tableHeaderView = headerView
	}
}
