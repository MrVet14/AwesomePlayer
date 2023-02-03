import Kingfisher
import SnapKit
import UIKit

class PlayerBarAboveAllViewsView: UIView {
	static let shared = PlayerBarAboveAllViewsView()

	var songToDisplay: SongObject? {
		didSet {
			guard let songToDisplay = self.songToDisplay else {
				return
			}

			songNameLabel.text = songToDisplay.name
			artistNameLabel.text = songToDisplay.artistName
			albumCoverImageView.kf.setImage(with: URL(string: songToDisplay.albumCoverURL), options: [.transition(.fade(0.1))])
			explicitLabel.isHidden = !songToDisplay.explicit
		}
	}

	var playerPlaying = true {
		didSet {
			let blurEffect = UIBlurEffect(
				style: playerPlaying ? UIBlurEffect.Style.systemUltraThinMaterial : UIBlurEffect.Style.systemThinMaterial
			)
			blurredBackground.effect = blurEffect

			playPauseButton.setImage(
				UIImage(
					systemName: playerPlaying ? "pause" : "play.fill",
					withConfiguration: UIImage.SymbolConfiguration(pointSize: 35, weight: .regular)
				),
				for: .normal
			)
		}
	}

	var didTapPlayPause: (() -> Void)?

	// MARK: Subviews
	let blurredBackground: UIVisualEffectView = {
		let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemUltraThinMaterial)
		let effect = UIVisualEffectView(effect: blurEffect)
		return effect
	}()

	let albumCoverImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(systemName: "photo")
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()

	let songNameLabel: MarqueeLabel = {
		let label = MarqueeLabel()
		label.font = .systemFont(ofSize: 16, weight: .semibold)
		label.numberOfLines = 1
		label.animationDelay = 2.0
		label.type = .leftRight
		return label
	}()

	let artistNameLabel: MarqueeLabel = {
		let label = MarqueeLabel()
		label.font = .systemFont(ofSize: 12, weight: .regular)
		label.textColor = .secondaryLabel
		label.numberOfLines = 1
		label.animationDelay = 2.0
		return label
	}()

	let explicitLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 10, weight: .heavy)
		label.textColor = .secondaryLabel
		label.text = L10n.explicit
		label.isHidden = true
		return label
	}()

	let playPauseButton: UIButton = {
		let button = UIButton()
		button.tintColor = .label
		button.setImage(UIImage(systemName: "pause"), for: .normal)
		return button
	}()

	// MARK: Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		clipsToBounds = true
		addSubview(blurredBackground)
		addSubview(albumCoverImageView)
		addSubview(playPauseButton)
		addSubview(songNameLabel)
		addSubview(artistNameLabel)
		addSubview(explicitLabel)

		playPauseButton.addTarget(self, action: #selector(didTapPlayPauseAction), for: .touchUpInside)
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	// MARK: Laying out constraints
	override func layoutSubviews() {
		super.layoutSubviews()

		blurredBackground.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		albumCoverImageView.snp.makeConstraints { make in
			make.width.equalTo(50)
			make.leading.top.equalToSuperview().offset(5)
			make.bottom.equalToSuperview().offset(-5)
		}

		playPauseButton.snp.makeConstraints { make in
			make.height.equalToSuperview()
			make.width.equalTo(40)
			make.centerY.equalToSuperview()
			make.trailing.equalToSuperview().offset(-15)
		}

		songNameLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(5)
			make.leading.equalTo(albumCoverImageView.snp.trailing).offset(7)
			make.trailing.equalTo(playPauseButton.snp.leading)
		}

		artistNameLabel.snp.makeConstraints { make in
			make.top.equalTo(songNameLabel.snp.bottom).offset(1)
			make.horizontalEdges.equalTo(songNameLabel)
		}

		explicitLabel.snp.makeConstraints { make in
			make.leading.equalTo(songNameLabel)
			make.bottom.equalToSuperview().offset(-5)
		}
	}

	// MARK: View logic
	@objc func didTapPlayPauseAction() {
		didTapPlayPause?()
	}
}
