import Kingfisher
import SnapKit
import UIKit

class PlaylistCollectionViewCell: UICollectionViewCell {
	static let identifier = "PlaylistCollectionViewCell"

	// MARK: Subviews
	let playlistCoverImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(systemName: "photo")
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()

	let playlistNameLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 20, weight: .semibold)
		label.numberOfLines = 1
		return label
	}()

	let descriptionLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .regular)
		label.textColor = .secondaryLabel
		label.numberOfLines = 2
		return label
	}()

	let numberOfTracksLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: .thin)
		label.textColor = .secondaryLabel
		label.text = L10n.explicit
		return label
	}()

	// MARK: Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.backgroundColor = .secondarySystemBackground
		contentView.clipsToBounds = true
		contentView.addSubview(playlistCoverImageView)
		contentView.addSubview(playlistNameLabel)
		contentView.addSubview(descriptionLabel)
		contentView.addSubview(numberOfTracksLabel)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Laying out constraints
	override func layoutSubviews() {
		super.layoutSubviews()

		playlistCoverImageView.snp.makeConstraints { make in
			make.height.width.equalTo(contentView.height - 20)
			make.top.leading.equalToSuperview().offset(10)
			make.bottom.equalToSuperview().offset(-10)
		}

		playlistNameLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(10)
			make.leading.equalTo(playlistCoverImageView.snp.trailing).offset(10)
			make.trailing.equalToSuperview().offset(-10)
		}

		descriptionLabel.snp.makeConstraints { make in
			make.top.equalTo(playlistNameLabel).offset(30)
			make.leading.equalTo(playlistNameLabel)
			make.trailing.equalToSuperview().offset(-10)
		}

		numberOfTracksLabel.snp.makeConstraints { make in
			make.leading.equalTo(playlistNameLabel)
			make.bottom.equalToSuperview().offset(-10)
		}
	}

	// MARK: Prepping cell for reuse
	override func prepareForReuse() {
		super.prepareForReuse()
		playlistNameLabel.text = nil
		descriptionLabel.text = nil
		playlistCoverImageView.image = nil
		numberOfTracksLabel.text = nil
	}

	// MARK: Configuring Cell with Data
	func configure(with viewModel: PlaylistCellViewModel) {
		playlistNameLabel.text = viewModel.name
		descriptionLabel.text = viewModel.description
		numberOfTracksLabel.text = "\(L10n.tracks): \(viewModel.numberOfTracks)"
		playlistCoverImageView.kf.setImage(with: URL(string: viewModel.playlistCoverURL), options: [.transition(.fade(0.1))])
	}
}
