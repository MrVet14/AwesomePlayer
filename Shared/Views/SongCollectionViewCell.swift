import Kingfisher
import SnapKit
import UIKit

class SongCollectionViewCell: UICollectionViewCell {
	static let identifier = "RecommendedSongCollectionViewCell"

	var likeButtonTapAction: (() -> Void)?

	// MARK: Subviews
	let albumCoverImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(systemName: "photo")
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()

	let songNameLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 18, weight: .semibold)
		label.numberOfLines = 1
		return label
	}()

	let artistNameLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: .regular)
		label.textColor = .secondaryLabel
		label.numberOfLines = 1
		return label
	}()

	let explicitLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12, weight: .heavy)
		label.textColor = .secondaryLabel
		label.text = L10n.explicit
		label.isHidden = true
		return label
	}()

	let likeButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(systemName: "heart"), for: .normal)
		button.tintColor = .label
		return button
	}()

	// MARK: Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.backgroundColor = .secondarySystemBackground
		contentView.clipsToBounds = true
		contentView.addSubview(albumCoverImageView)
		contentView.addSubview(likeButton)
		contentView.addSubview(songNameLabel)
		contentView.addSubview(artistNameLabel)
		contentView.addSubview(explicitLabel)
		likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Laying out constraints
	override func layoutSubviews() {
		super.layoutSubviews()

		albumCoverImageView.snp.makeConstraints { make in
			make.height.width.equalTo(contentView.height - 15)
			make.top.leading.equalToSuperview().offset(10)
			make.bottom.equalToSuperview().offset(-10)
		}

		songNameLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(5)
			make.leading.equalTo(albumCoverImageView.snp.trailing).offset(10)
			make.trailing.equalToSuperview().offset(-5)
		}

		artistNameLabel.snp.makeConstraints { make in
			make.top.equalTo(songNameLabel).offset(25)
			make.leading.equalTo(songNameLabel)
			make.trailing.equalTo(likeButton.snp.leading).offset(-10)
		}

		explicitLabel.snp.makeConstraints { make in
			make.leading.equalTo(songNameLabel)
			make.bottom.equalToSuperview().offset(-10)
		}

		likeButton.snp.makeConstraints { make in
			make.bottom.equalToSuperview().offset(-13)
			make.trailing.equalToSuperview().offset(-10)
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
		likeButton.setImage(
			UIImage(
				systemName: viewModel.liked ? "heart.fill" : "heart",
				withConfiguration:
					UIImage.SymbolConfiguration(
					pointSize: 24, weight: .regular
				)
			),
			for: .normal
		)
	}

	// MARK: Handling Like Button Tap
	@objc func likeButtonTapped(_ sender: UIButton) {
		likeButtonTapAction?()
	}
}
