import SnapKit
import UIKit

protocol GettingDataToDisplay {
	func loadData()
	func loadNonEssentialData()
	func getDataFromDB(completion: @escaping (() -> Void))
	func configureModels()
}

final class MainViewController: UIViewController {
	var featuredPlaylists: [PlaylistObject] = []
	var recommendedSongs: [SongObject] = []

	var sections = [MainViewSectionType]()

	var alreadyLoadedPlaylists: [String] = []

    // MARK: - Subviews
	var collectionView = UICollectionView(
		frame: .zero,
		collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
			return MainViewController().createSectionLayout(section: sectionIndex)
	 })

	lazy var indicatorView: UIActivityIndicatorView = {
		let view = UIActivityIndicatorView(style: .medium)
		view.color = .white
		view.hidesWhenStopped = true
		view.startAnimating()
		return view
	}()

    // MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

		setupViews()
		loadData()

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(configureModels),
			name: Notification.Name(NotificationCenterConstants.playerVCClosed),
			object: nil
		)
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		configureModels()
	}

    // MARK: Adding different elements to view
	private func setupViews() {
		view.backgroundColor = .systemBackground

		let settingsButton = UIBarButtonItem(
			image: UIImage(systemName: "gear"),
			style: .plain,
			target: self,
			action: #selector(didTapSettings)
		)
		settingsButton.tintColor = .label
		navigationItem.rightBarButtonItems = [settingsButton]

		view.addSubview(collectionView)
		registeringCollectionViewCells()
		collectionView.dataSource = self
		collectionView.delegate = self

		collectionView.isHidden = true

		view.addSubview(indicatorView)
    }

	// MARK: Laying out constraints
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		collectionView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		indicatorView.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
	}

	// MARK: Handling possible errors
	func handlingErrorDuringLoadingData(error: Error) {
		print(error.localizedDescription)

		HapticsManager.shared.vibrate(for: .error)

		let alert = UIAlertController(
			title: L10n.somethingWentWrong,
			message: L10n.tryRestartingAppOrPressReload,
			preferredStyle: .alert
		)
		alert.addAction(
			UIAlertAction(
				title: L10n.reload,
				style: .default,
				handler: { [weak self] _ in
					self?.loadData()
				}
			)
		)
		present(alert, animated: true)
	}

	// MARK: Controller logic
	// Switching to settings View
	@objc private func didTapSettings() {
		let settingsVC = SettingsViewController()
		settingsVC.navigationItem.largeTitleDisplayMode = .never
		navigationController?.pushViewController(settingsVC, animated: true)
	}

	// Processing tap on like button
	func processLikeButtonTappedAction(
		id: String,
		liked: Bool
	) {
		TrackHandlerManager.shared.processLikeButtonTappedAction(
			id: id,
			liked: liked
		) {
			self.configureModels()
		}
	}
}
