import Kingfisher
import SnapKit
import UIKit

class SettingsViewController: UIViewController {
	var sections = [Section]()

	// MARK: - Subviews
	let tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .grouped)
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		return tableView
	}()

	// MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

		setupViews()
		configureModels()

		tableView.dataSource = self
		tableView.delegate = self
    }

	// MARK: Creating Models for tableView
	func configureModels() {
		sections.append(Section(title: L10n.profile, options: [
			Option(title: L10n.viewProfile, handler: { [weak self] in
			DispatchQueue.main.async {
				self?.didTapProfile()
			}
		})
		]))
		sections.append(Section(title: L10n.account, options: [
			Option(title: L10n.signOut, handler: { [weak self] in
			DispatchQueue.main.async {
				self?.signOut()
			}
		})
		]))
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

	// MARK: Methods to interact with View
	func didTapProfile() {
		let profileVC = ProfileViewController()
		profileVC.navigationItem.largeTitleDisplayMode = .never
		navigationController?.pushViewController(profileVC, animated: true)
	}

	func signOut() {
		let alert = UIAlertController(title: L10n.signOut, message: L10n.areYouSure, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: L10n.signOut, style: .destructive, handler: { _ in
			AuthManager.shared.signOut { [weak self] _ in
				let welcomeVC = UINavigationController(rootViewController: WelcomeViewController())
				welcomeVC.modalPresentationStyle = .fullScreen
				self?.present(welcomeVC, animated: true, completion: {
					self?.navigationController?.popToRootViewController(animated: false)
				})
			}
		}))
		present(alert, animated: true)
	}
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
	// MARK: TableView set up
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

		if cellModel.title == L10n.signOut {
			cell.textLabel?.textColor = .systemRed
		}

		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		HapticsManager.shared.vibrateForSelection()

		let cellModel = sections[indexPath.section].options[indexPath.row]
		cellModel.handler()
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let sectionModel = sections[section]
		return sectionModel.title
	}
}
