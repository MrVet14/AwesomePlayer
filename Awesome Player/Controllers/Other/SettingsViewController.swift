import SnapKit
import UIKit
// swiftlint:disable all
class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	var sections = [Section]()

	// MARK: Creating view elements
	let tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .grouped)
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		return tableView
	}()

	// MARK: App lifesycle
    override func viewDidLoad() {
        super.viewDidLoad()

		configureModels()
		setupViews()

		tableView.dataSource = self
		tableView.delegate = self
    }

	// MARK: Creating Models for tableView
	func configureModels() {
		sections.append(Section(title: "Profile", options: [Option(title: "View Profile", handler: { [weak self] in
			DispatchQueue.main.async {
				self?.didTapProfile()
			}
		})]))
		sections.append(Section(title: "Accaunt", options: [Option(title: "Sign Out", handler: { [weak self] in
			DispatchQueue.main.async {
				self?.signOut()
			}
		})]))
	}

	// MARK: Adding view elements to View & configuring them
	func setupViews() {
		title = L10n.settings
		view.backgroundColor = .systemBackground

		view.addSubview(tableView)
	}
	
	// MARK: Setting Constraints
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		tableView.frame = view.bounds
	}

	// MARK: tableView set up
	func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].options.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellModel = sections[indexPath.section].options[indexPath.row]

		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = cellModel.title
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		let cellModel = sections[indexPath.section].options[indexPath.row]
		cellModel.handler()
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let sectionModel = sections[section]
		return sectionModel.title
	}

	// MARK: Methods to interact with View
	func didTapProfile() {
		let profileVC = ProfileViewController()
		profileVC.navigationItem.largeTitleDisplayMode = .never
		navigationController?.pushViewController(profileVC, animated: true)
	}
	
	func signOut() {
		AuthManager.shared.signOut { _ in
			print("Signed Out")
		}
	}
}
