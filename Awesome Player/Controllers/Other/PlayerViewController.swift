import Kingfisher
import SnapKit
import UIKit

protocol PlayerControlsDelegate: AnyObject {
	func didTapPlayPause()
	func didTapBack()
	func didTapNext()
	func tappedOnTheSongInListOfOtherSongs(songIndex: Int)
}

class PlayerViewController: UIViewController {
	static let shared = PlayerViewController(songToDisplay: SongObject())

	private init(songToDisplay: SongObject) {
		self.songToDisplay = songToDisplay
		super.init(nibName: nil, bundle: nil)
	}

	// swiftlint:disable fatal_error
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	weak var delegate: PlayerControlsDelegate?

	var songToDisplay: SongObject? {
		didSet {
			guard let songToDisplay = songToDisplay else {
				print("Song to display in PlayerVC is not existent")
				return
			}

			collectionView.backgroundColor = .clear
			imageView.kf.setImage(
				with: URL(string: songToDisplay.albumCoverURL),
				options: [.transition(.fade(0.1))]
			)
			songTitleLabel.text = songToDisplay.name
			songArtistNameLabel.text = songToDisplay.artistName
			explicitLabel.isHidden = !songToDisplay.explicit
			updateLikeButton()

			collectionView.reloadData()
		}
	}

	var playerPlaying = true {
		didSet {
			playPauseButton.setImage(
				UIImage(
					systemName: playerPlaying ? "pause" : "play.fill",
					withConfiguration: UIImage.SymbolConfiguration(pointSize: 42, weight: .regular)
				),
				for: .normal
			)
		}
	}

	var listOfOtherSong: [SongObject] = []
	var listOfOtherSongsModel: [SongCellViewModel] {
		listOfOtherSong.compactMap {
			return SongCellViewModel(
				id: $0.id,
				name: $0.name,
				albumCoverURL: $0.albumCoverURL,
				artistName: $0.artistName,
				explicit: $0.explicit,
				liked: $0.liked)
		}
	}

	// MARK: - Subviews
	let blurredBackground: UIVisualEffectView = {
		let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemUltraThinMaterial)
		let effect = UIVisualEffectView(effect: blurEffect)
		return effect
	}()

	let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()

	let songTitleLabel: MarqueeLabel = {
		let label = MarqueeLabel()
		label.font = .systemFont(ofSize: 22, weight: .semibold)
		label.numberOfLines = 1
		label.animationDelay = 2.0
		label.type = .leftRight
		return label
	}()

	let songArtistNameLabel: MarqueeLabel = {
		let label = MarqueeLabel()
		label.font = .systemFont(ofSize: 18, weight: .regular)
		label.textColor = .secondaryLabel
		label.numberOfLines = 1
		label.animationDelay = 2.0
		return label
	}()

	let explicitLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: .heavy)
		label.textColor = .secondaryLabel
		label.text = L10n.explicit
		label.isHidden = true
		return label
	}()

	let backButton: UIButton = {
		let button = UIButton()
		button.tintColor = .label
		button.setImage(
			UIImage(
				systemName: "backward.fill",
				withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .regular)
			),
			for: .normal
		)
		return button
	}()

	let playPauseButton: UIButton = {
		let button = UIButton()
		button.tintColor = .label
		button.setImage(UIImage(systemName: "pause"), for: .normal)
		return button
	}()

	let nextButton: UIButton = {
		let button = UIButton()
		button.tintColor = .label
		button.setImage(
			UIImage(
				systemName: "forward.fill",
				withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .regular)
			),
			for: .normal
		)
		return button
	}()

	let shareButton: UIButton = {
		let button = UIButton()
		button.tintColor = .label
		button.setImage(
			UIImage(
				systemName: "square.and.arrow.up",
				withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
			),
			for: .normal
		)
		return button
	}()

	let likeButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(systemName: "heart"), for: .normal)
		button.tintColor = .label
		return button
	}()

	var collectionView = UICollectionView(
		frame: .zero,
		collectionViewLayout: UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
			// Item
			let item = NSCollectionLayoutItem(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0),
					heightDimension: .fractionalHeight(1.0))
			)
			item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 3)

			// Group
			let group = NSCollectionLayoutGroup.horizontal(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .absolute(140),
					heightDimension: .absolute(190)
				),
				subitem: item,
				count: 1
			)

			// Section
			let section = NSCollectionLayoutSection(group: group)
			section.orthogonalScrollingBehavior = .continuous
			return section
		})

	// MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

		delegate = PlayerPresenter.shared

		setupViews()

		playPauseButton.addTarget(self, action: #selector(didTapPlayPauseButton), for: .touchUpInside)
		backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
		nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
		shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
		likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
    }

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		// Sending signal to reload VCs data when player window closed
		NotificationCenter.default.post(name: Notification.Name(NotificationCenterConstants.playerVCClosed), object: nil)
	}

	// MARK: Filling View with Data
	func updateLikeButton() {
		guard let songToDisplay = songToDisplay else {
			print("Song to display in PlayerVC is not existent")
			return
		}

		likeButton.setImage(
			UIImage(
				systemName: songToDisplay.liked ? "heart.fill" : "heart",
				withConfiguration: UIImage.SymbolConfiguration(pointSize: 26, weight: .regular)
			),
			for: .normal
		)
	}

	// MARK: Logic for the controller
	@objc
	func didTapPlayPauseButton() {
		delegate?.didTapPlayPause()
	}

	@objc
	func didTapBackButton() {
		delegate?.didTapBack()
	}

	@objc
	func didTapNextButton() {
		delegate?.didTapNext()
	}

	@objc
	func didTapShareButton() {
		guard let songToDisplay = songToDisplay else {
			print("Song to display in PlayerVC is not existent")
			return
		}

		let songToShare = APIConstants.baseURLForSharingSongs + songToDisplay.id
		let items = [
			// Song Name
			songToDisplay.name,
			// Link to Song
			songToShare
		]

		let activityAC = UIActivityViewController(activityItems: items, applicationActivities: nil)
		present(activityAC, animated: true)
	}

	@objc
	func didTapLikeButton() {
		guard let songToDisplay = songToDisplay else {
			print("Song to display in PlayerVC is not existent")
			return
		}

		TrackHandlerManager.shared.processLikeButtonTappedAction(
			id: songToDisplay.id,
			liked: songToDisplay.liked
		) { [weak self] in
			self?.updateLikeButton()
		}
	}
}
