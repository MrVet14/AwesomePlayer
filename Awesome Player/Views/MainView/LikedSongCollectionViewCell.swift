import Kingfisher
import SnapKit
import UIKit

class LikedSongCollectionViewCell: UICollectionViewCell {
	static let identifier = "LikedSongCollectionViewCell"

	var likeButtonTapAction: (() -> Void)?

	let albumCoverImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(systemName: "photo")
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()

	let songNameLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 20, weight: .semibold)
		label.numberOfLines = 1
		return label
	}()

	let artistNameLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .regular)
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

	let likeButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(systemName: "heart"), for: .normal)
		button.imageView?.contentMode = .scaleAspectFit
		button.tintColor = .label
		return button
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.backgroundColor = .secondarySystemBackground
		contentView.clipsToBounds = true
		contentView.addSubview(albumCoverImageView)
		contentView.addSubview(songNameLabel)
		contentView.addSubview(artistNameLabel)
		contentView.addSubview(explicitLabel)
		contentView.addSubview(likeButton)
		likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
	}
	// swiftlint:disable fatal_error
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		albumCoverImageView.snp.makeConstraints { make in
			make.height.width.equalTo(contentView.height - 20)
			make.top.leading.equalToSuperview().offset(10)
			make.bottom.equalToSuperview().offset(-10)
		}

		songNameLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(20)
			make.leading.equalTo(albumCoverImageView.snp.trailing).offset(10)
			make.trailing.equalToSuperview().offset(-10)
		}

		artistNameLabel.snp.makeConstraints { make in
			make.top.equalTo(songNameLabel).offset(30)
			make.leading.equalTo(songNameLabel)
			make.trailing.equalToSuperview().offset(-10)
		}

		explicitLabel.snp.makeConstraints { make in
			make.leading.equalTo(songNameLabel)
			make.bottom.equalToSuperview().offset(-10)
		}

		likeButton.snp.makeConstraints { make in
			make.bottom.trailing.equalToSuperview().offset(-10)
		}
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		songNameLabel.text = nil
		artistNameLabel.text = nil
		albumCoverImageView.image = nil
		songNameLabel.snp.removeConstraints()
	}

	func configure(with viewModel: SongCellViewModel) {
		if viewModel.id.isEmpty {
			useDummyCellWithText()
		}
		songNameLabel.text = viewModel.name
		artistNameLabel.text = viewModel.artistName
		albumCoverImageView.kf.setImage(with: URL(string: viewModel.albumCoverURL), options: [.transition(.fade(0.1))])
		if viewModel.explicit {
			explicitLabel.isHidden = false
		} else {
			explicitLabel.isHidden = true
		}
		if viewModel.liked {
			likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
		}
	}

	func useDummyCellWithText() {
		albumCoverImageView.isHidden = true
		likeButton.isHidden = true
		explicitLabel.isHidden = true

		songNameLabel.snp.remakeConstraints { make in
			make.leading.equalToSuperview().offset(10)
		}
	}

	@objc
	func likeButtonTapped(_ sender: UIButton) {
		likeButtonTapAction?()
	}
}
