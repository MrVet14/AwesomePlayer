import Kingfisher
import SnapKit
import UIKit

class PlayerViewController: UIViewController {
	var songToDisplay = SongObject()

	// MARK: - Subviews
	let blurredBackground: UIVisualEffectView = {
		let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
		let effect = UIVisualEffectView(effect: blurEffect)
		return effect
	}()

	let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()

	let songTitleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 22, weight: .semibold)
		label.numberOfLines = 1
		return label
	}()

	let songArtistNameLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 18, weight: .regular)
		label.textColor = .secondaryLabel
		label.numberOfLines = 1
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
		button.setImage(
			UIImage(
				systemName: "pause",
				withConfiguration: UIImage.SymbolConfiguration(pointSize: 42, weight: .regular)
			),
			for: .normal
		)
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
		button.setImage(
			UIImage(systemName: "heart"), for: .normal)
		button.tintColor = .label
		return button
	}()

	// MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

		setupViews()
		configureView()
    }

	// MARK: Adding view elements to View & configuring them
	func setupViews() {
		view.addSubview(blurredBackground)

		view.addSubview(imageView)
		view.addSubview(songTitleLabel)
		view.addSubview(songArtistNameLabel)
		view.addSubview(explicitLabel)

		view.addSubview(backButton)
		view.addSubview(playPauseButton)
		view.addSubview(nextButton)
		view.addSubview(shareButton)
		view.addSubview(likeButton)

		view.clipsToBounds = true
	}

	// MARK: Adding constraints to subviews
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		blurredBackground.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		imageView.snp.makeConstraints { make in
			make.height.equalTo(370)
			make.top.equalToSuperview().offset(20)
			make.leading.equalToSuperview().offset(20)
			make.trailing.equalToSuperview().offset(-20)
		}

		songTitleLabel.snp.makeConstraints { make in
			make.top.equalTo(imageView.snp.bottom).offset(20)
			make.leading.equalToSuperview().offset(20)
			make.trailing.equalToSuperview().offset(-20)
		}

		songArtistNameLabel.snp.makeConstraints { make in
			make.top.equalTo(songTitleLabel.snp.bottom).offset(3)
			make.horizontalEdges.equalTo(songTitleLabel)
		}

		explicitLabel.snp.makeConstraints { make in
			make.top.equalTo(imageView.snp.bottom).offset(5)
			make.trailing.equalTo(imageView)
		}

		playPauseButton.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalTo(songArtistNameLabel.snp.bottom).offset(70)
		}

		backButton.snp.makeConstraints { make in
			make.top.equalTo(playPauseButton).offset(4)
			make.trailing.equalTo(playPauseButton.snp.leading).offset(-30)
		}

		nextButton.snp.makeConstraints { make in
			make.top.equalTo(playPauseButton).offset(4)
			make.leading.equalTo(playPauseButton.snp.trailing).offset(30)
		}

		shareButton.snp.makeConstraints { make in
			make.top.equalTo(playPauseButton)
			make.trailing.equalTo(backButton.snp.leading).offset(-30)
		}

		likeButton.snp.makeConstraints { make in
			make.top.equalTo(playPauseButton).offset(6)
			make.leading.equalTo(nextButton.snp.trailing).offset(30)
		}
	}

	// MARK: Filling View with Data
	func configureView() {
		imageView.kf.setImage(
			with: URL(string: songToDisplay.albumCoverURL),
			options: [.transition(.fade(0.1))]
		)
		songTitleLabel.text = songToDisplay.name
		songArtistNameLabel.text = songToDisplay.artistName
		explicitLabel.isHidden = !songToDisplay.explicit
		likeButton.setImage(
			UIImage(
				systemName: songToDisplay.liked ? "heart.fill" : "heart",
				withConfiguration: UIImage.SymbolConfiguration(pointSize: 26, weight: .regular)
			),
			for: .normal
		)
	}
}
