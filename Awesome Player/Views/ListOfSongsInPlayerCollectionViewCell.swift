import Kingfisher
import SnapKit
import UIKit

class ListOfSongsInPlayerCollectionViewCell: UICollectionViewCell {
	static let identifier = "RecommendedSongInPlayerViewCollectionViewCell"

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

	let songNameLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .semibold)
		label.numberOfLines = 1
		return label
	}()

	let artistNameLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12, weight: .regular)
		label.textColor = .secondaryLabel
		label.numberOfLines = 1
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

	// MARK: Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.clipsToBounds = true
		contentView.addSubview(blurredBackground)
		contentView.addSubview(albumCoverImageView)
		contentView.addSubview(songNameLabel)
		contentView.addSubview(artistNameLabel)
		contentView.addSubview(explicitLabel)
		contentView.layer.cornerRadius = 10
	}

	// swiftlint:disable fatal_error
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Laying out constraints
	override func layoutSubviews() {
		super.layoutSubviews()

		blurredBackground.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		albumCoverImageView.snp.makeConstraints { make in
			make.leading.top.equalToSuperview().offset(10)
			make.trailing.equalToSuperview().offset(-10)
			make.height.equalTo(120)
		}

		songNameLabel.snp.makeConstraints { make in
			make.top.equalTo(albumCoverImageView.snp.bottom).offset(10)
			make.horizontalEdges.equalTo(albumCoverImageView)
		}

		artistNameLabel.snp.makeConstraints { make in
			make.top.equalTo(songNameLabel.snp.bottom).offset(1)
			make.horizontalEdges.equalTo(songNameLabel)
		}

		explicitLabel.snp.makeConstraints { make in
			make.top.equalTo(albumCoverImageView.snp.bottom).offset(1)
			make.trailing.equalTo(albumCoverImageView)
		}
	}

	// MARK: Prepping cell for reuse
	override func prepareForReuse() {
		super.prepareForReuse()
		songNameLabel.text = nil
		artistNameLabel.text = nil
		albumCoverImageView.image = nil
	}

	// MARK: Configuring Cell with Data
	func configure(with viewModel: SongCellViewModel) {
		songNameLabel.text = viewModel.name
		artistNameLabel.text = viewModel.artistName
		albumCoverImageView.kf.setImage(with: URL(string: viewModel.albumCoverURL), options: [.transition(.fade(0.1))])
		explicitLabel.isHidden = !viewModel.explicit
	}
}
